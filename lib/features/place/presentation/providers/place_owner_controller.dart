import 'package:commonplant_frontend/core/config/app_environment.dart';
import 'package:commonplant_frontend/core/network/user_data_session.dart';
import 'package:commonplant_frontend/features/place/place_feature_provider.dart';
import 'package:commonplant_frontend/features/place/place_repository_provider.dart';
import 'package:commonplant_frontend/features/place/presentation/providers/friend_management_members_provider.dart';
import 'package:commonplant_frontend/features/place/presentation/providers/place_detail_remote_provider.dart';
import 'package:commonplant_frontend/features/place/presentation/providers/place_list_provider.dart';
import 'package:commonplant_frontend/shared/forms/form_submit_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final placeOwnerControllerProvider = NotifierProvider.autoDispose
    .family<PlaceOwnerController, FormSubmitState, String>(
      PlaceOwnerController.new,
    );

class PlaceOwnerController extends Notifier<FormSubmitState> {
  PlaceOwnerController(this.placeCode);

  final String placeCode;

  @override
  FormSubmitState build() {
    if (ref.watch(useRemoteApiProvider)) ref.watch(userDataSessionProvider);
    return const FormSubmitState.idle();
  }

  Future<bool> transferTo(String targetNanoId) async {
    if (state.isSubmitting) return false;

    if (!ref.read(useRemoteApiProvider)) {
      state = const FormSubmitState.failure('팀짱 변경은 서버 연결 후 이용할 수 있어요');
      return false;
    }

    final requestRef = ref;
    final session = ref.read(userDataSessionProvider);
    if (!session.isActive) {
      state = const FormSubmitState.failure('로그인 후 다시 시도해 주세요');
      return false;
    }
    if (placeCode.trim().isEmpty) {
      state = const FormSubmitState.failure('장소 정보를 확인한 뒤 다시 시도해 주세요');
      return false;
    }

    final detail = ref
        .read(placeDetailProvider(placeCode))
        .unwrapPrevious()
        .value;
    if (detail?.isOwner != true) {
      state = const FormSubmitState.failure('팀짱 권한을 확인한 뒤 다시 시도해 주세요');
      return false;
    }

    final targetId = targetNanoId.trim();
    final members = ref
        .read(friendManagementMembersProvider(placeCode))
        .unwrapPrevious()
        .value;
    final isCurrentMember =
        targetId.isNotEmpty &&
        members != null &&
        members.any(
          (member) => member.id == targetId && member.isOwner == false,
        );
    if (!isCurrentMember) {
      state = const FormSubmitState.failure('팀짱으로 변경할 현재 멤버를 다시 선택해 주세요');
      return false;
    }

    state = const FormSubmitState.submitting();
    try {
      await ref
          .read(placeRepositoryProvider)
          .changePlaceOwner(code: placeCode, targetNanoId: targetId);
      if (!isCurrentUserDataSession(requestRef, session)) return false;

      state = const FormSubmitState.idle();
      ref.invalidate(placeDetailProvider(placeCode));
      ref.invalidate(placeSummaryProvider(placeCode));
      ref.invalidate(remoteFriendManagementMembersProvider(placeCode));
      ref.invalidate(remotePlaceListProvider);
      ref.invalidate(userPlaceSummariesProvider);
      return true;
    } catch (error) {
      if (!isCurrentUserDataSession(requestRef, session)) return false;
      state = FormSubmitState.failureFrom(
        error,
        fallbackMessage: '팀짱 변경에 실패했어요',
      );
      return false;
    }
  }
}
