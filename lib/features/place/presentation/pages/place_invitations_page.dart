import 'package:commonplant_frontend/core/assets/app_image_assets.dart';
import 'package:commonplant_frontend/core/theme/app_colors.dart';
import 'package:commonplant_frontend/core/theme/app_radius.dart';
import 'package:commonplant_frontend/core/theme/app_sizes.dart';
import 'package:commonplant_frontend/core/theme/app_spacing.dart';
import 'package:commonplant_frontend/core/theme/app_text_styles.dart';
import 'package:commonplant_frontend/shared/widgets/common_scaffold.dart';
import 'package:flutter/material.dart';

const double _invitationContentGap = 14;
const double _invitationButtonGap = 8;
const double _invitationItemGap = 24;

enum _InvitationResult { accepted, deleted }

class PlaceInvitationsPage extends StatefulWidget {
  const PlaceInvitationsPage({super.key});

  @override
  State<PlaceInvitationsPage> createState() => _PlaceInvitationsPageState();
}

class _PlaceInvitationsPageState extends State<PlaceInvitationsPage> {
  final Map<String, _InvitationResult> _results = <String, _InvitationResult>{};

  static const List<_PlaceInvitation> _invitations = [
    _PlaceInvitation(
      id: 'invite-1',
      inviterName: '커먼맘',
      placeName: '스윗홈_욕실',
      address: '서울시 노원구 광운로 20',
      avatarAsset: AppImageAssets.placeInvitationAvatarCommonMom,
    ),
    _PlaceInvitation(
      id: 'invite-2',
      inviterName: '커먼맘',
      placeName: '스윗홈_베란다',
      address: '서울시 노원구 광운로 20',
      avatarAsset: AppImageAssets.placeInvitationAvatarCommonMom,
    ),
    _PlaceInvitation(
      id: 'invite-3',
      inviterName: '도라에몽',
      placeName: '낫 스윗 회사_중앙',
      address: '서울시 강남구 커먼로 55',
      avatarAsset: AppImageAssets.placeInvitationAvatarDoraemon,
      avatarAlignment: Alignment.topCenter,
    ),
  ];

  void _setResult(String id, _InvitationResult result) {
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
          for (final invitation in _invitations) ...[
            _InvitationListItem(
              invitation: invitation,
              result: _results[invitation.id],
              onAccept: () =>
                  _setResult(invitation.id, _InvitationResult.accepted),
              onDelete: () =>
                  _setResult(invitation.id, _InvitationResult.deleted),
            ),
            if (invitation.id != _invitations.last.id)
              const SizedBox(height: _invitationItemGap),
          ],
        ],
      ),
    );
  }
}

class _InvitationListItem extends StatelessWidget {
  const _InvitationListItem({
    required this.invitation,
    required this.result,
    required this.onAccept,
    required this.onDelete,
  });

  final _PlaceInvitation invitation;
  final _InvitationResult? result;
  final VoidCallback onAccept;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _InvitationAvatar(invitation: invitation),
        const SizedBox(width: _invitationContentGap),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _InvitationDescription(invitation: invitation, result: result),
              const SizedBox(height: _invitationButtonGap),
              if (result == null)
                _InvitationActions(
                  invitation: invitation,
                  onAccept: onAccept,
                  onDelete: onDelete,
                )
              else
                const SizedBox(
                  height: AppSizes.placeInvitationActionButtonHeight,
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _InvitationAvatar extends StatelessWidget {
  const _InvitationAvatar({required this.invitation});

  final _PlaceInvitation invitation;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '${invitation.inviterName} 프로필 사진',
      image: true,
      child: ClipOval(
        child: Image.asset(
          invitation.avatarAsset,
          width: AppSizes.placeInvitationAvatarSize,
          height: AppSizes.placeInvitationAvatarSize,
          fit: BoxFit.cover,
          alignment: invitation.avatarAlignment,
        ),
      ),
    );
  }
}

class _InvitationDescription extends StatelessWidget {
  const _InvitationDescription({
    required this.invitation,
    required this.result,
  });

  final _PlaceInvitation invitation;
  final _InvitationResult? result;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          invitation.inviterName,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppTextStyles.size16Bold.copyWith(
            color: AppColors.textHeadline,
          ),
        ),
        const SizedBox(height: AppSpacing.x4),
        if (result == null)
          _InvitationPlaceLine(invitation: invitation)
        else
          _InvitationResultText(invitation: invitation, result: result!),
      ],
    );
  }
}

class _InvitationPlaceLine extends StatelessWidget {
  const _InvitationPlaceLine({required this.invitation});

  final _PlaceInvitation invitation;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          invitation.placeName,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppTextStyles.size14Bold.copyWith(color: AppColors.textStrong),
        ),
        const SizedBox(width: AppSpacing.x4),
        Flexible(
          child: Text(
            invitation.address,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.size12Medium.copyWith(
              color: AppColors.textBody,
            ),
          ),
        ),
      ],
    );
  }
}

class _InvitationResultText extends StatelessWidget {
  const _InvitationResultText({required this.invitation, required this.result});

  final _PlaceInvitation invitation;
  final _InvitationResult result;

  @override
  Widget build(BuildContext context) {
    final message = switch (result) {
      _InvitationResult.accepted => '${invitation.placeName}에서 함께 해보세요:)',
      _InvitationResult.deleted => '요청 삭제됨',
    };

    final color = switch (result) {
      _InvitationResult.accepted => AppColors.brandStrong,
      _InvitationResult.deleted => AppColors.textStrong,
    };

    return Text(
      message,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: AppTextStyles.size14Medium.copyWith(color: color),
    );
  }
}

class _InvitationActions extends StatelessWidget {
  const _InvitationActions({
    required this.invitation,
    required this.onAccept,
    required this.onDelete,
  });

  final _PlaceInvitation invitation;
  final VoidCallback onAccept;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _InvitationActionButton(
          label: '확인',
          semanticsLabel: '${invitation.placeName} 확인',
          backgroundColor: AppColors.brandPrimary,
          foregroundColor: AppColors.white,
          onPressed: onAccept,
        ),
        const SizedBox(width: _invitationButtonGap),
        _InvitationActionButton(
          label: '삭제',
          semanticsLabel: '${invitation.placeName} 삭제',
          backgroundColor: AppColors.borderDefault,
          foregroundColor: AppColors.textStrong,
          onPressed: onDelete,
        ),
      ],
    );
  }
}

class _InvitationActionButton extends StatelessWidget {
  const _InvitationActionButton({
    required this.label,
    required this.semanticsLabel,
    required this.backgroundColor,
    required this.foregroundColor,
    required this.onPressed,
  });

  final String label;
  final String semanticsLabel;
  final Color backgroundColor;
  final Color foregroundColor;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: semanticsLabel,
      button: true,
      container: true,
      child: ExcludeSemantics(
        child: Material(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(AppRadius.small),
          child: InkWell(
            onTap: onPressed,
            borderRadius: BorderRadius.circular(AppRadius.small),
            child: SizedBox(
              width: AppSizes.placeInvitationActionButtonWidth,
              height: AppSizes.placeInvitationActionButtonHeight,
              child: Center(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.size14Bold.copyWith(
                    color: foregroundColor,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PlaceInvitation {
  const _PlaceInvitation({
    required this.id,
    required this.inviterName,
    required this.placeName,
    required this.address,
    required this.avatarAsset,
    this.avatarAlignment = Alignment.center,
  });

  final String id;
  final String inviterName;
  final String placeName;
  final String address;
  final String avatarAsset;
  final Alignment avatarAlignment;
}
