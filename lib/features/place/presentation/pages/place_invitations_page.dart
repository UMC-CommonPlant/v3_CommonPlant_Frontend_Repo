import 'package:commonplant_frontend/core/theme/app_colors.dart';
import 'package:commonplant_frontend/core/theme/app_spacing.dart';
import 'package:commonplant_frontend/core/theme/app_text_styles.dart';
import 'package:commonplant_frontend/features/common/presentation/widgets/phase0_widgets.dart';
import 'package:commonplant_frontend/shared/widgets/common_button.dart';
import 'package:commonplant_frontend/shared/widgets/common_scaffold.dart';
import 'package:flutter/material.dart';

class PlaceInvitationsPage extends StatefulWidget {
  const PlaceInvitationsPage({super.key});

  @override
  State<PlaceInvitationsPage> createState() => _PlaceInvitationsPageState();
}

class _PlaceInvitationsPageState extends State<PlaceInvitationsPage> {
  final Map<String, String> _statuses = <String, String>{};

  static const List<_PlaceInvitation> _invitations = [
    _PlaceInvitation(
      id: 'invite-1',
      placeName: '성수 작업실',
      inviter: '커먼 파파',
      memberCount: 4,
    ),
    _PlaceInvitation(
      id: 'invite-2',
      placeName: '테라스 정원',
      inviter: '초록이',
      memberCount: 2,
    ),
    _PlaceInvitation(
      id: 'invite-3',
      placeName: '우리 동네 식물방',
      inviter: '식집사',
      memberCount: 8,
    ),
  ];

  void _updateStatus(String id, String status) {
    setState(() => _statuses[id] = status);
  }

  @override
  Widget build(BuildContext context) {
    return CommonScaffold(
      title: '장소 친구 요청',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '초대받은 장소',
            style: AppTextStyles.size24Medium.copyWith(
              color: AppColors.textHeadline,
            ),
          ),
          const SizedBox(height: AppSpacing.x8),
          Text(
            '함께 관리할 장소 요청을 확인하고 참여 여부를 선택해 주세요.',
            style: AppTextStyles.size16Medium.copyWith(
              color: AppColors.textBody,
            ),
          ),
          const SizedBox(height: AppSpacing.x24),
          for (final invitation in _invitations) ...[
            _InvitationCard(
              invitation: invitation,
              status: _statuses[invitation.id],
              onAccept: () => _updateStatus(invitation.id, '수락 완료'),
              onReject: () => _updateStatus(invitation.id, '거절 완료'),
            ),
            const SizedBox(height: AppSpacing.x12),
          ],
        ],
      ),
    );
  }
}

class _InvitationCard extends StatelessWidget {
  const _InvitationCard({
    required this.invitation,
    required this.status,
    required this.onAccept,
    required this.onReject,
  });

  final _PlaceInvitation invitation;
  final String? status;
  final VoidCallback onAccept;
  final VoidCallback onReject;

  @override
  Widget build(BuildContext context) {
    return Phase0Surface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Phase0UserAvatar(label: invitation.inviter.characters.first),
              const SizedBox(width: AppSpacing.x12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      invitation.placeName,
                      style: AppTextStyles.size16Bold.copyWith(
                        color: AppColors.textStrong,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.x4),
                    Text(
                      '${invitation.inviter} 님이 초대했어요 · ${invitation.memberCount}명 참여 중',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.size14Medium.copyWith(
                        color: AppColors.textBody,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.x16),
          if (status == null)
            Row(
              children: [
                Expanded(
                  child: CommonButton.secondary(
                    label: '거절',
                    size: CommonButtonSize.medium,
                    onPressed: onReject,
                  ),
                ),
                const SizedBox(width: AppSpacing.x8),
                Expanded(
                  child: CommonButton(
                    label: '수락',
                    size: CommonButtonSize.medium,
                    onPressed: onAccept,
                  ),
                ),
              ],
            )
          else
            Phase0Chip(label: status!, isActive: status == '수락 완료'),
        ],
      ),
    );
  }
}

class _PlaceInvitation {
  const _PlaceInvitation({
    required this.id,
    required this.placeName,
    required this.inviter,
    required this.memberCount,
  });

  final String id;
  final String placeName;
  final String inviter;
  final int memberCount;
}
