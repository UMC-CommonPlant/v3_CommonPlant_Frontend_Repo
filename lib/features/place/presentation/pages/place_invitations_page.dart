import 'package:commonplant_frontend/core/theme/app_colors.dart';
import 'package:commonplant_frontend/core/theme/app_text_styles.dart';
import 'package:commonplant_frontend/features/place/presentation/fixtures/place_invitation_fixture.dart';
import 'package:commonplant_frontend/features/place/presentation/providers/place_invitation_controller.dart';
import 'package:commonplant_frontend/features/place/presentation/widgets/place_invitation_list_item.dart';
import 'package:commonplant_frontend/shared/widgets/common_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

const double _invitationItemGap = 24;

class PlaceInvitationsPage extends ConsumerWidget {
  const PlaceInvitationsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(placeInvitationControllerProvider);
    final controller = ref.read(placeInvitationControllerProvider.notifier);

    return CommonScaffold(
      title: '장소 친구 요청',
      navigationTitleStyle: AppTextStyles.size18Medium.copyWith(
        color: AppColors.textStrong,
        fontWeight: FontWeight.w700,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final invitation in placeInvitationFixture) ...[
            PlaceInvitationListItem(
              invitation: invitation,
              result: state.resultFor(invitation.id),
              onAccept: () => controller.accept(invitation.id),
              onDelete: () => controller.delete(invitation.id),
            ),
            if (invitation.id != placeInvitationFixture.last.id)
              const SizedBox(height: _invitationItemGap),
          ],
        ],
      ),
    );
  }
}
