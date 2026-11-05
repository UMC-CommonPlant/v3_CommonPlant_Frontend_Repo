import 'package:commonplant_frontend/core/config/app_environment.dart';
import 'package:commonplant_frontend/core/network/user_data_session.dart';
import 'package:commonplant_frontend/features/place/place_feature_provider.dart';
import 'package:commonplant_frontend/features/place/place_repository_provider.dart';
import 'package:commonplant_frontend/features/place/presentation/providers/friend_management_members_provider.dart';
import 'package:commonplant_frontend/features/place/presentation/providers/place_detail_remote_provider.dart';
import 'package:commonplant_frontend/features/place/presentation/providers/place_list_provider.dart';
import 'package:commonplant_frontend/features/plant/presentation/providers/plant_detail_remote_provider.dart';
import 'package:commonplant_frontend/features/plant/presentation/providers/plant_form_edit_provider.dart';
import 'package:commonplant_frontend/features/plant/presentation/providers/plant_list_provider.dart';
import 'package:commonplant_frontend/features/plant/presentation/providers/plant_place_code_provider.dart';
import 'package:commonplant_frontend/shared/forms/form_submit_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final placeExitControllerProvider =
    NotifierProvider<PlaceExitController, FormSubmitState>(
      PlaceExitController.new,
    );

class PlaceExitController extends Notifier<FormSubmitState> {
  @override
  FormSubmitState build() {
    if (ref.watch(useRemoteApiProvider)) ref.watch(userDataSessionProvider);
    return const FormSubmitState.idle();
  }

  Future<bool> exit(String placeId) => _submit(placeId, isLeaving: false);

  Future<bool> leave(String placeId) => _submit(placeId, isLeaving: true);

  Future<bool> _submit(String placeId, {required bool isLeaving}) async {
    if (state.isSubmitting) {
      return false;
    }

    if (!ref.read(useRemoteApiProvider)) {
      state = const FormSubmitState.idle();
      return false;
    }

    final requestRef = ref;
    final session = ref.read(userDataSessionProvider);
    if (!session.isActive) return false;
    final code = placeId.trim();
    if (code.isEmpty) {
      state = const FormSubmitState.failure('장소 정보를 확인할 수 없어요.');
      return false;
    }

    final detailProvider = placeDetailProvider(code);
    // 재조회 중 이전 값은 권한 판단이 아닌 관련 캐시 제거에만 사용한다.
    final cachedDetail = ref.exists(detailProvider)
        ? ref.read(detailProvider).value
        : null;
    final affectedPlantIds = {
      for (final plant in cachedDetail?.plants ?? [])
        if (plant.id.trim().isNotEmpty) plant.id.trim(),
    };
    state = const FormSubmitState.submitting();

    try {
      final repository = ref.read(placeRepositoryProvider);
      if (isLeaving) {
        await repository.leavePlace(code);
      } else {
        await repository.deletePlace(code);
      }
      if (!isCurrentUserDataSession(requestRef, session)) return false;

      state = const FormSubmitState.idle();
      ref.invalidate(detailProvider);
      ref.invalidate(placeSummaryProvider(code));
      ref.invalidate(remoteFriendManagementMembersProvider(code));
      ref.invalidate(remotePlaceListProvider);
      ref.invalidate(userPlaceSummariesProvider);
      ref.invalidate(remotePlantListProvider);
      for (final plantId in affectedPlantIds) {
        ref.invalidate(remotePlantDetailProvider(plantId));
        ref.invalidate(remotePlantEditInfoProvider(plantId));
        ref.invalidate(remotePlantPlaceCodeProvider(plantId));
      }

      return true;
    } catch (error) {
      if (!isCurrentUserDataSession(requestRef, session)) return false;
      state = FormSubmitState.failureFrom(
        error,
        fallbackMessage: isLeaving ? '장소 나가기에 실패했어요' : '장소 삭제에 실패했어요',
      );

      return false;
    }
  }
}
