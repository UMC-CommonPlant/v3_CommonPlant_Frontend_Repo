import 'package:commonplant_frontend/core/config/app_environment.dart';
import 'package:commonplant_frontend/features/friend/data/dtos/friend_requests.dart';
import 'package:commonplant_frontend/features/friend/data/repositories/friend_repository.dart';
import 'package:commonplant_frontend/features/place/presentation/models/place_friend_profile.dart';
import 'package:commonplant_frontend/shared/forms/form_submit_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final placeFriendRequestControllerProvider =
    NotifierProvider.autoDispose<PlaceFriendRequestController, FormSubmitState>(
      PlaceFriendRequestController.new,
    );

class PlaceFriendRequestController extends Notifier<FormSubmitState> {
  @override
  FormSubmitState build() => const FormSubmitState.idle();

  Future<bool> submit({
    required String? placeCode,
    required List<PlaceFriendProfile> friends,
  }) async {
    if (state.isSubmitting) {
      return false;
    }

    if (friends.isEmpty || !ref.read(useRemoteApiProvider)) {
      return true;
    }

    final normalizedPlaceCode = placeCode?.trim();
    if (normalizedPlaceCode == null || normalizedPlaceCode.isEmpty) {
      state = const FormSubmitState.failure('장소 정보를 확인할 수 없어요');
      return false;
    }

    final receiverNames = friends
        .map((friend) => friend.name.trim())
        .where((name) => name.isNotEmpty)
        .toList(growable: false);
    if (receiverNames.length != friends.length) {
      state = const FormSubmitState.failure('선택한 사용자 정보를 확인할 수 없어요');
      return false;
    }

    state = const FormSubmitState.submitting();

    try {
      await ref
          .read(friendRepositoryProvider)
          .sendRequest(
            SendFriendRequest(
              receiverNames: receiverNames,
              placeCode: normalizedPlaceCode,
            ),
          );
      if (!ref.mounted) {
        return true;
      }

      state = const FormSubmitState.idle();
      return true;
    } catch (_) {
      if (!ref.mounted) {
        return false;
      }

      state = const FormSubmitState.failure('친구 요청을 보내지 못했어요');
      return false;
    }
  }
}
