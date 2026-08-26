import 'dart:async';

import 'package:commonplant_frontend/core/config/app_environment.dart';
import 'package:commonplant_frontend/core/theme/app_colors.dart';
import 'package:commonplant_frontend/core/theme/app_sizes.dart';
import 'package:commonplant_frontend/core/theme/app_spacing.dart';
import 'package:commonplant_frontend/core/theme/app_text_styles.dart';
import 'package:commonplant_frontend/features/place/presentation/models/place_invitation.dart';
import 'package:commonplant_frontend/features/place/presentation/providers/place_invitation_controller.dart';
import 'package:commonplant_frontend/features/place/presentation/widgets/place_invitation_list_item.dart';
import 'package:commonplant_frontend/shared/widgets/common_button.dart';
import 'package:commonplant_frontend/shared/widgets/common_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

const double _invitationItemGap = 24;

class PlaceInvitationsPage extends ConsumerWidget {
  const PlaceInvitationsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final invitations = ref.watch(placeInvitationsProvider);
    final state = ref.watch(placeInvitationControllerProvider);
    final usesRemoteApi = ref.watch(useRemoteApiProvider);

    return CommonScaffold(
      title: '장소 친구 요청',
      navigationTitleStyle: AppTextStyles.size18Medium.copyWith(
        color: AppColors.textStrong,
        fontWeight: FontWeight.w700,
      ),
      child: invitations.when(
        data: (items) => _InvitationContent(
          invitations: usesRemoteApi
              ? items
                    .where((item) => state.resultFor(item.id) == null)
                    .toList(growable: false)
              : items,
          state: state,
          usesRemoteApi: usesRemoteApi,
        ),
        error: (error, stackTrace) => _InvitationStatus(
          title: '친구 요청을 불러오지 못했어요',
          message: '잠시 후 다시 시도해 주세요',
          actionLabel: '다시 시도',
          onAction: () => ref.invalidate(remotePlaceInvitationsProvider),
        ),
        loading: () => const _InvitationStatus(
          title: '친구 요청을 불러오고 있어요',
          message: '받은 장소 요청을 확인하고 있어요',
          isLoading: true,
        ),
      ),
    );
  }
}

class _InvitationContent extends ConsumerWidget {
  const _InvitationContent({
    required this.invitations,
    required this.state,
    required this.usesRemoteApi,
  });

  final List<PlaceInvitation> invitations;
  final PlaceInvitationState state;
  final bool usesRemoteApi;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (invitations.isEmpty) {
      return const _InvitationStatus(
        title: '받은 장소 요청이 없어요',
        message: '새로운 요청이 오면 이곳에서 확인할 수 있어요',
      );
    }

    final controller = ref.read(placeInvitationControllerProvider.notifier);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (state.actionErrorMessage case final errorMessage?) ...[
          Text(
            errorMessage,
            style: AppTextStyles.size14Medium.copyWith(color: AppColors.danger),
          ),
          const SizedBox(height: AppSpacing.x16),
        ],
        for (final (index, invitation) in invitations.indexed) ...[
          PlaceInvitationListItem(
            invitation: invitation,
            result: state.resultFor(invitation.id),
            isSubmitting: state.isSubmitting(invitation.id),
            onAccept: () => unawaited(
              controller.accept(
                invitation.id,
                friendId: usesRemoteApi ? invitation.friendId : null,
              ),
            ),
            onDelete: () => unawaited(
              controller.delete(
                invitation.id,
                friendId: usesRemoteApi ? invitation.friendId : null,
              ),
            ),
          ),
          if (index != invitations.length - 1)
            const SizedBox(height: _invitationItemGap),
        ],
      ],
    );
  }
}

class _InvitationStatus extends StatelessWidget {
  const _InvitationStatus({
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
    this.isLoading = false,
  });

  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: AppSizes.mobileWidth,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isLoading) ...[
              const CircularProgressIndicator(color: AppColors.brandPrimary),
              const SizedBox(height: AppSpacing.x20),
            ],
            Text(
              title,
              textAlign: TextAlign.center,
              style: AppTextStyles.size18Medium.copyWith(
                color: AppColors.textStrong,
              ),
            ),
            const SizedBox(height: AppSpacing.x8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: AppTextStyles.size14Medium.copyWith(
                color: AppColors.textBody,
              ),
            ),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: AppSpacing.x24),
              CommonButton.secondary(
                label: actionLabel!,
                onPressed: onAction,
                size: CommonButtonSize.small,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
