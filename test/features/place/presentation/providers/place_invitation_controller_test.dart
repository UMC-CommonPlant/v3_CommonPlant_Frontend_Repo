import 'package:commonplant_frontend/features/place/presentation/models/place_invitation.dart';
import 'package:commonplant_frontend/features/place/presentation/providers/place_invitation_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('초대를 수락하면 accepted 결과를 저장한다', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    container
        .read(placeInvitationControllerProvider.notifier)
        .accept('invite-1');

    expect(
      container.read(placeInvitationControllerProvider).resultFor('invite-1'),
      PlaceInvitationResult.accepted,
    );
  });

  test('초대를 삭제하면 deleted 결과를 저장한다', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    container
        .read(placeInvitationControllerProvider.notifier)
        .delete('invite-2');

    expect(
      container.read(placeInvitationControllerProvider).resultFor('invite-2'),
      PlaceInvitationResult.deleted,
    );
  });
}
