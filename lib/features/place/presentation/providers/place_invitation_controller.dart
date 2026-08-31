import 'package:commonplant_frontend/core/assets/app_image_assets.dart';
import 'package:commonplant_frontend/core/config/app_environment.dart';
import 'package:commonplant_frontend/core/network/api_exception.dart';
import 'package:commonplant_frontend/core/network/user_data_session.dart';
import 'package:commonplant_frontend/features/friend/data/dtos/friend_requests.dart';
import 'package:commonplant_frontend/features/friend/data/repositories/friend_repository.dart';
import 'package:commonplant_frontend/features/friend/domain/entities/friend_invitation.dart';
import 'package:commonplant_frontend/features/place/presentation/fixtures/place_invitation_fixture.dart';
import 'package:commonplant_frontend/features/place/presentation/models/place_invitation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final remotePlaceInvitationsProvider =
    FutureProvider.autoDispose<List<PlaceInvitation>>((ref) async {
      requireUserDataSession(ref);
      final invitations = await ref
          .watch(friendRepositoryProvider)
          .fetchRequests();

      return List.unmodifiable(invitations.map(_toPlaceInvitation));
    }, retry: (retryCount, error) => null);

final placeInvitationsProvider =
    Provider.autoDispose<AsyncValue<List<PlaceInvitation>>>((ref) {
      if (ref.watch(useRemoteApiProvider)) {
        return ref.watch(remotePlaceInvitationsProvider).unwrapPrevious();
      }

      return const AsyncData(placeInvitationFixture);
    });

final placeInvitationControllerProvider =
    NotifierProvider.autoDispose<
      PlaceInvitationController,
      PlaceInvitationState
    >(PlaceInvitationController.new);

final placeInvitationRequestCountProvider =
    Provider.autoDispose<AsyncValue<int>>((ref) {
      final invitations = ref.watch(placeInvitationsProvider);
      final results = ref.watch(
        placeInvitationControllerProvider.select((state) => state.results),
      );

      return invitations.whenData(
        (items) => items.where((item) => results[item.id] == null).length,
      );
    });

class PlaceInvitationState {
  const PlaceInvitationState({
    required this.results,
    required this.submittingIds,
    this.actionErrorMessage,
  });

  const PlaceInvitationState.initial()
    : results = const {},
      submittingIds = const {},
      actionErrorMessage = null;

  final Map<String, PlaceInvitationResult> results;
  final Set<String> submittingIds;
  final String? actionErrorMessage;

  PlaceInvitationResult? resultFor(String invitationId) {
    return results[invitationId];
  }

  bool isSubmitting(String invitationId) {
    return submittingIds.contains(invitationId);
  }
}

class PlaceInvitationController extends Notifier<PlaceInvitationState> {
  @override
  PlaceInvitationState build() {
    if (ref.watch(useRemoteApiProvider)) ref.watch(userDataSessionProvider);
    return const PlaceInvitationState.initial();
  }

  Future<void> accept(String invitationId, {int? friendId}) {
    return _resolve(
      invitationId: invitationId,
      friendId: friendId,
      result: PlaceInvitationResult.accepted,
      remoteAction: (request) =>
          ref.read(friendRepositoryProvider).acceptRequest(request),
    );
  }

  Future<void> delete(String invitationId, {int? friendId}) {
    return _resolve(
      invitationId: invitationId,
      friendId: friendId,
      result: PlaceInvitationResult.deleted,
      remoteAction: (request) =>
          ref.read(friendRepositoryProvider).declineRequest(request),
    );
  }

  Future<void> _resolve({
    required String invitationId,
    required int? friendId,
    required PlaceInvitationResult result,
    required Future<void> Function(FriendDecisionRequest) remoteAction,
  }) async {
    if (state.resultFor(invitationId) != null ||
        state.isSubmitting(invitationId)) {
      return;
    }

    if (!ref.read(useRemoteApiProvider)) {
      _setResult(invitationId, result);
      return;
    }

    final requestRef = ref;
    final session = ref.read(userDataSessionProvider);
    if (!session.isActive) return;
    if (friendId == null) {
      _setActionFailure('친구 요청 정보를 확인할 수 없어요');
      return;
    }

    _setSubmitting(invitationId);

    try {
      await remoteAction(FriendDecisionRequest(friendId: friendId));
      if (!isCurrentUserDataSession(requestRef, session)) return;
      _setResult(invitationId, result);
      ref.invalidate(remotePlaceInvitationsProvider);
    } catch (error) {
      if (!isCurrentUserDataSession(requestRef, session)) return;
      _setActionFailure(
        apiUserMessage(error, fallback: '친구 요청을 처리하지 못했어요'),
        invitationId,
      );
    }
  }

  void _setSubmitting(String invitationId) {
    state = PlaceInvitationState(
      results: state.results,
      submittingIds: Set.unmodifiable({...state.submittingIds, invitationId}),
    );
  }

  void _setResult(String invitationId, PlaceInvitationResult result) {
    state = PlaceInvitationState(
      results: Map.unmodifiable({...state.results, invitationId: result}),
      submittingIds: Set.unmodifiable(
        Set<String>.of(state.submittingIds)..remove(invitationId),
      ),
    );
  }

  void _setActionFailure(String message, [String? invitationId]) {
    final submittingIds = Set<String>.of(state.submittingIds);
    if (invitationId != null) {
      submittingIds.remove(invitationId);
    }

    state = PlaceInvitationState(
      results: state.results,
      submittingIds: Set.unmodifiable(submittingIds),
      actionErrorMessage: message,
    );
  }
}

PlaceInvitation _toPlaceInvitation(FriendInvitation invitation) {
  return PlaceInvitation(
    id: invitation.id.toString(),
    friendId: invitation.id,
    inviterName: invitation.senderName,
    placeName: invitation.placeName,
    address: invitation.placeAddress,
    avatarAsset: AppImageAssets.leafAvatarPlaceholder,
    avatarImageUrl: invitation.senderImageUrl,
  );
}
