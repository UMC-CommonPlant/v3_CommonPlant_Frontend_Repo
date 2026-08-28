import 'package:commonplant_frontend/core/config/app_environment.dart';
import 'package:commonplant_frontend/core/network/user_data_session.dart';
import 'package:commonplant_frontend/features/memo/presentation/providers/memo_list_provider.dart';
import 'package:commonplant_frontend/features/memo/presentation/providers/memo_write_controller.dart';
import 'package:commonplant_frontend/features/place/presentation/models/place_friend_profile.dart';
import 'package:commonplant_frontend/features/place/presentation/providers/friend_management_controller.dart';
import 'package:commonplant_frontend/features/place/presentation/providers/place_form_controller.dart';
import 'package:commonplant_frontend/features/place/presentation/providers/place_friend_selection_controller.dart';
import 'package:commonplant_frontend/features/place/presentation/providers/place_list_provider.dart';
import 'package:commonplant_frontend/features/plant/presentation/providers/plant_list_provider.dart';
import 'package:commonplant_frontend/features/user/presentation/providers/user_settings_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/user_data_session.dart';

void main() {
  for (final useRemote in [true, false]) {
    test(
      useRemote
          ? '계정 전환은 사용자 초안·선택·로컬 추가 데이터를 초기화한다'
          : 'API 비사용 fixture 상태는 데이터 세션 전환으로 바꾸지 않는다',
      () {
        final container = ProviderContainer(
          overrides: [
            authenticatedUserDataSession,
            useRemoteApiProvider.overrideWithValue(useRemote),
          ],
        );
        addTearDown(container.dispose);
        final placeForm = placeFormControllerProvider(null);
        final memoForm = memoWriteControllerProvider('shared-plant');
        final members = friendManagementControllerProvider('shared-place');
        container.listen(placeForm, (_, _) {});
        container.listen(memoForm, (_, _) {});
        container.listen(members, (_, _) {});
        container.listen(placeFriendSelectionControllerProvider, (_, _) {});
        container.listen(userNotificationSettingProvider, (_, _) {});

        container.read(placeListProvider.notifier).addPlace(name: 'A 장소');
        container.read(plantListProvider.notifier).addPlant(name: 'A 식물');
        container
            .read(memoListProvider.notifier)
            .addMemo(plantId: 'shared-plant', content: 'A 메모');
        container.read(placeForm.notifier).updateName('A 초안');
        container.read(memoForm.notifier).updateContent('A 내용');
        container.read(members.notifier).updateQuery('A 검색');
        container
            .read(userNotificationSettingProvider.notifier)
            .setEnabled(false);
        final selection = container.read(
          placeFriendSelectionControllerProvider.notifier,
        );
        selection.updateQuery('A 친구');
        selection.toggle(
          const PlaceFriendProfile(id: 'friend-A', name: 'A 친구'),
        );

        container.read(userDataSessionProvider.notifier).start();

        expect(container.read(placeListProvider).isEmpty, useRemote);
        expect(container.read(plantListProvider).isEmpty, useRemote);
        expect(
          container.read(memoItemsProvider('shared-plant')).isEmpty,
          useRemote,
        );
        expect(container.read(placeForm).currentName, useRemote ? '' : 'A 초안');
        expect(container.read(memoForm).content, useRemote ? '' : 'A 내용');
        expect(container.read(members).query, useRemote ? '' : 'A 검색');
        expect(container.read(userNotificationSettingProvider), useRemote);
        expect(
          container.read(placeFriendSelectionControllerProvider).query,
          useRemote ? '' : 'A 친구',
        );
        expect(
          container
              .read(placeFriendSelectionControllerProvider)
              .selectedFriends
              .isEmpty,
          useRemote,
        );
      },
    );
  }
}
