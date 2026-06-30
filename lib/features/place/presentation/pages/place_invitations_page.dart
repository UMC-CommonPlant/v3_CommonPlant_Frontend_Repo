import 'package:commonplant_frontend/core/theme/app_colors.dart';
import 'package:commonplant_frontend/core/theme/app_text_styles.dart';
import 'package:commonplant_frontend/features/place/presentation/fixtures/place_invitation_fixture.dart';
import 'package:commonplant_frontend/features/place/presentation/models/place_invitation.dart';
import 'package:commonplant_frontend/features/place/presentation/widgets/place_invitation_list_item.dart';
import 'package:commonplant_frontend/shared/widgets/common_scaffold.dart';
import 'package:flutter/material.dart';

const double _invitationItemGap = 24;

class PlaceInvitationsPage extends StatefulWidget {
  const PlaceInvitationsPage({super.key});

  @override
  State<PlaceInvitationsPage> createState() => _PlaceInvitationsPageState();
}

class _PlaceInvitationsPageState extends State<PlaceInvitationsPage> {
  final Map<String, PlaceInvitationResult> _results =
      <String, PlaceInvitationResult>{};

  void _setResult(String id, PlaceInvitationResult result) {
    setState(() => _results[id] = result);
  }

  @override
  Widget build(BuildContext context) {
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
              result: _results[invitation.id],
              onAccept: () =>
                  _setResult(invitation.id, PlaceInvitationResult.accepted),
              onDelete: () =>
                  _setResult(invitation.id, PlaceInvitationResult.deleted),
            ),
            if (invitation.id != placeInvitationFixture.last.id)
              const SizedBox(height: _invitationItemGap),
          ],
        ],
      ),
    );
  }
}
