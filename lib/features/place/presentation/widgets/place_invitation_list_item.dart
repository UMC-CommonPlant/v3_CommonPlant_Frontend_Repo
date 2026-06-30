import 'package:commonplant_frontend/core/theme/app_colors.dart';
import 'package:commonplant_frontend/core/theme/app_radius.dart';
import 'package:commonplant_frontend/core/theme/app_sizes.dart';
import 'package:commonplant_frontend/core/theme/app_spacing.dart';
import 'package:commonplant_frontend/core/theme/app_text_styles.dart';
import 'package:commonplant_frontend/features/place/presentation/models/place_invitation.dart';
import 'package:flutter/material.dart';

const double _invitationContentGap = 14;
const double _invitationButtonGap = 8;

class PlaceInvitationListItem extends StatelessWidget {
  const PlaceInvitationListItem({
    super.key,
    required this.invitation,
    required this.result,
    required this.onAccept,
    required this.onDelete,
  });

  final PlaceInvitation invitation;
  final PlaceInvitationResult? result;
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

  final PlaceInvitation invitation;

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

  final PlaceInvitation invitation;
  final PlaceInvitationResult? result;

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

  final PlaceInvitation invitation;

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

  final PlaceInvitation invitation;
  final PlaceInvitationResult result;

  @override
  Widget build(BuildContext context) {
    final message = switch (result) {
      PlaceInvitationResult.accepted => '${invitation.placeName}에서 함께 해보세요:)',
      PlaceInvitationResult.deleted => '요청 삭제됨',
    };

    final color = switch (result) {
      PlaceInvitationResult.accepted => AppColors.brandStrong,
      PlaceInvitationResult.deleted => AppColors.textStrong,
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

  final PlaceInvitation invitation;
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
