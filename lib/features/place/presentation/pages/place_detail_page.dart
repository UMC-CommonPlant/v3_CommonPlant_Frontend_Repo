import 'dart:async';

import 'package:commonplant_frontend/app/router/route_paths.dart';
import 'package:commonplant_frontend/core/assets/app_icon_assets.dart';
import 'package:commonplant_frontend/core/theme/app_colors.dart';
import 'package:commonplant_frontend/core/theme/app_sizes.dart';
import 'package:commonplant_frontend/core/theme/app_spacing.dart';
import 'package:commonplant_frontend/core/theme/app_text_styles.dart';
import 'package:commonplant_frontend/features/place/presentation/fixtures/place_detail_fixture.dart';
import 'package:commonplant_frontend/features/place/presentation/models/place_detail_role.dart';
import 'package:commonplant_frontend/features/place/presentation/providers/place_detail_view_provider.dart';
import 'package:commonplant_frontend/features/place/presentation/providers/place_exit_controller.dart';
import 'package:commonplant_frontend/features/place/presentation/widgets/place_detail_fab.dart';
import 'package:commonplant_frontend/features/place/presentation/widgets/place_detail_header.dart';
import 'package:commonplant_frontend/features/place/presentation/widgets/place_exit_dialog.dart';
import 'package:commonplant_frontend/features/place/presentation/widgets/place_plant_list.dart';
import 'package:commonplant_frontend/shared/widgets/common_button.dart';
import 'package:commonplant_frontend/shared/widgets/common_scaffold.dart';
import 'package:commonplant_frontend/shared/widgets/common_svg_icon.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class PlaceDetailPage extends ConsumerStatefulWidget {
  const PlaceDetailPage({super.key, required this.placeId, this.role});

  final String placeId;
  final PlaceDetailRole? role;

  @override
  ConsumerState<PlaceDetailPage> createState() => _PlaceDetailPageState();
}

class _PlaceDetailPageState extends ConsumerState<PlaceDetailPage> {
  void _showExitDialog(BuildContext context) {
    final isExiting = ref.read(placeExitControllerProvider).isSubmitting;

    unawaited(
      showPlaceExitDialog(
        context: context,
        isExiting: isExiting,
        onConfirm: () => _handleExitConfirmed(context),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final request = (placeId: widget.placeId, role: widget.role);
    final detailState = ref.watch(placeDetailViewProvider(request));

    return detailState.when(
      data: (detail) {
        if (detail == null) {
          return _buildStatusScaffold(
            context,
            const _PlaceDetailStatusView(
              icon: AppIconAssets.placeEmpty,
              title: '장소 정보를 찾을 수 없어요',
              message: '다시 장소 목록에서 선택해 주세요',
              semanticsLabel: '장소 정보 없음',
            ),
          );
        }

        return _buildScaffold(context, detail);
      },
      error: (error, stackTrace) {
        return _buildStatusScaffold(
          context,
          _PlaceDetailStatusView(
            icon: AppIconAssets.placeEmpty,
            title: '장소 정보를 불러오지 못했어요',
            message: '잠시 후 다시 시도해 주세요',
            semanticsLabel: '장소 정보 오류',
            actionLabel: '다시 시도',
            onAction: () => invalidatePlaceDetailView(ref, request),
          ),
        );
      },
      loading: () {
        return _buildStatusScaffold(
          context,
          const _PlaceDetailStatusView(
            title: '장소 정보를 불러오고 있어요',
            message: '장소와 식물 정보를 준비하고 있어요',
            isLoading: true,
          ),
        );
      },
    );
  }

  void _handleExitConfirmed(BuildContext context) {
    Navigator.of(context).pop();
    unawaited(_handleExitResult(context));
  }

  Future<void> _handleExitResult(BuildContext context) async {
    final result = await ref
        .read(placeExitControllerProvider.notifier)
        .exit(widget.placeId);

    if (!mounted || !context.mounted) {
      return;
    }

    if (result?.destination == PlaceExitDestination.home) {
      context.go(AppRoutePaths.home);
      return;
    }

    final errorMessage = ref.read(placeExitControllerProvider).errorMessage;

    if (errorMessage == null) {
      return;
    }

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(errorMessage)));
  }

  Widget _buildScaffold(BuildContext context, PlaceDetailFixtureData detail) {
    return CommonScaffold(
      title: 'My place',
      navigationTitleStyle: AppTextStyles.size18Medium.copyWith(
        color: AppColors.textStrong,
        fontWeight: FontWeight.w700,
      ),
      bodyPadding: EdgeInsets.zero,
      floatingActionButton: PlaceDetailFab(
        placeId: widget.placeId,
        canEditPlace: detail.role == PlaceDetailRole.leader,
        onExit: () => _showExitDialog(context),
      ),
      child: SizedBox(
        width: double.infinity,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: AppSizes.mobileWidth),
            child: Column(
              children: [
                PlaceDetailHeader(
                  placeId: widget.placeId,
                  name: detail.name,
                  address: detail.address,
                  sunlightLabel: detail.sunlightLabel,
                  humidityLabel: detail.humidityLabel,
                  friends: detail.friends,
                ),
                PlacePlantList(placeId: widget.placeId, plants: detail.plants),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusScaffold(BuildContext context, Widget child) {
    return CommonScaffold(
      title: 'My place',
      navigationTitleStyle: AppTextStyles.size18Medium.copyWith(
        color: AppColors.textStrong,
        fontWeight: FontWeight.w700,
      ),
      bodyPadding: EdgeInsets.zero,
      child: SizedBox(
        width: double.infinity,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: AppSizes.mobileWidth),
            child: SizedBox(height: AppSizes.mobileWidth, child: child),
          ),
        ),
      ),
    );
  }
}

class _PlaceDetailStatusView extends StatelessWidget {
  const _PlaceDetailStatusView({
    required this.title,
    required this.message,
    this.icon,
    this.semanticsLabel,
    this.actionLabel,
    this.onAction,
    this.isLoading = false,
  });

  final String title;
  final String message;
  final String? icon;
  final String? semanticsLabel;
  final String? actionLabel;
  final VoidCallback? onAction;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.x20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isLoading)
              SizedBox.square(
                dimension: AppSizes.iconLarge,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    AppColors.brandStrong,
                  ),
                ),
              )
            else if (icon case final icon?)
              CommonSvgIcon(
                icon,
                width: AppSizes.iconLarge,
                height: AppSizes.iconLarge,
                color: AppColors.iconInactive,
                semanticsLabel: semanticsLabel,
              ),
            const SizedBox(height: AppSpacing.x16),
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
              SizedBox(
                width: AppSizes.smallButtonWidth,
                child: CommonButton.secondary(
                  label: actionLabel!,
                  size: CommonButtonSize.medium,
                  onPressed: onAction,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
