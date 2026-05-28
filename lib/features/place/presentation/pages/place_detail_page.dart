import 'dart:async';

import 'package:commonplant_frontend/app/router/route_paths.dart';
import 'package:commonplant_frontend/core/assets/app_icon_assets.dart';
import 'package:commonplant_frontend/core/assets/app_image_assets.dart';
import 'package:commonplant_frontend/core/config/app_environment.dart';
import 'package:commonplant_frontend/core/theme/app_colors.dart';
import 'package:commonplant_frontend/core/theme/app_radius.dart';
import 'package:commonplant_frontend/core/theme/app_sizes.dart';
import 'package:commonplant_frontend/core/theme/app_spacing.dart';
import 'package:commonplant_frontend/core/theme/app_text_styles.dart';
import 'package:commonplant_frontend/features/place/data/repositories/place_repository.dart';
import 'package:commonplant_frontend/features/place/presentation/providers/place_list_provider.dart';
import 'package:commonplant_frontend/features/place/presentation/widgets/place_friend_selection_widgets.dart';
import 'package:commonplant_frontend/shared/forms/form_submit_controller.dart';
import 'package:commonplant_frontend/shared/widgets/common_button.dart';
import 'package:commonplant_frontend/shared/widgets/common_dialog.dart';
import 'package:commonplant_frontend/shared/widgets/common_fab.dart';
import 'package:commonplant_frontend/shared/widgets/common_plant_card.dart';
import 'package:commonplant_frontend/shared/widgets/common_scaffold.dart';
import 'package:commonplant_frontend/shared/widgets/common_svg_icon.dart';
import 'package:commonplant_frontend/shared/widgets/common_watering_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

enum PlaceDetailRole { leader, member }

PlaceDetailRole? placeDetailRoleFromQuery(String? value) {
  return switch (value) {
    'leader' => PlaceDetailRole.leader,
    'member' || 'team' => PlaceDetailRole.member,
    _ => null,
  };
}

class PlaceDetailPage extends ConsumerStatefulWidget {
  const PlaceDetailPage({super.key, required this.placeId, this.role});

  final String placeId;
  final PlaceDetailRole? role;

  @override
  ConsumerState<PlaceDetailPage> createState() => _PlaceDetailPageState();
}

class _PlaceDetailPageState extends ConsumerState<PlaceDetailPage> {
  late final FormSubmitController _exitController;

  bool get _isExiting => _exitController.state.isSubmitting;

  @override
  void initState() {
    super.initState();
    _exitController = FormSubmitController()
      ..addListener(_handleExitStateChanged);
  }

  @override
  void dispose() {
    _exitController
      ..removeListener(_handleExitStateChanged)
      ..dispose();
    super.dispose();
  }

  void _handleExitStateChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  void _showExitDialog(BuildContext context) {
    showCommonDialog<void>(
      context: context,
      child: CommonDialogCard(
        title: '장소를 나가시겠어요?',
        message: '나가면 더 이상 식물을 관리할 수 없어요.',
        actions: [
          CommonDialogActionButton(
            label: '취소',
            foregroundColor: AppColors.textBody,
            onPressed: () => Navigator.of(context).pop(),
          ),
          CommonDialogActionButton.confirm(
            label: '나가기',
            foregroundColor: AppColors.danger,
            onPressed: _isExiting ? null : () => _confirmExit(context),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final mockDetail = _PlaceDetailData.mock(widget.placeId, role: widget.role);

    if (!ref.watch(useRemoteApiProvider)) {
      return _buildScaffold(context, mockDetail);
    }

    final remoteDetail = ref.watch(placeDetailProvider(widget.placeId));

    return remoteDetail.when(
      data: (summary) {
        if (_isEmptyRemoteSummary(summary)) {
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

        return _buildScaffold(context, mockDetail.applySummary(summary));
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
            onAction: () => ref.invalidate(placeDetailProvider(widget.placeId)),
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

  void _confirmExit(BuildContext context) {
    Navigator.of(context).pop();
    unawaited(_exitPlace(context));
  }

  Future<void> _exitPlace(BuildContext context) async {
    if (!ref.read(useRemoteApiProvider)) {
      return;
    }

    await _exitController.submit(() async {
      await ref.read(placeRepositoryProvider).deletePlace(widget.placeId);
      ref.invalidate(placeDetailProvider(widget.placeId));
      ref.invalidate(remotePlaceListProvider);
      ref.invalidate(plantRegistrationPlaceProvider);
    }, failureMessage: '장소 나가기에 실패했어요');

    if (!mounted || !context.mounted) {
      return;
    }

    if (_exitController.state.hasError) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_exitController.state.errorMessage!)),
      );
      return;
    }

    context.go(AppRoutePaths.home);
  }

  Widget _buildScaffold(BuildContext context, _PlaceDetailData detail) {
    return CommonScaffold(
      title: 'My place',
      navigationTitleStyle: AppTextStyles.size18Medium.copyWith(
        color: AppColors.textStrong,
        fontWeight: FontWeight.w700,
      ),
      bodyPadding: EdgeInsets.zero,
      floatingActionButton: _PlaceDetailFab(
        placeId: widget.placeId,
        role: detail.role,
        onExit: () => _showExitDialog(context),
      ),
      child: SizedBox(
        width: double.infinity,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: AppSizes.mobileWidth),
            child: Column(
              children: [
                _PlaceDetailHeader(detail: detail, placeId: widget.placeId),
                _PlacePlantList(placeId: widget.placeId, plants: detail.plants),
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

  bool _isEmptyRemoteSummary(PlaceSummary summary) {
    return summary.name.trim().isEmpty;
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

class _PlaceDetailData {
  const _PlaceDetailData({
    required this.role,
    required this.name,
    required this.address,
    required this.sunlightLabel,
    required this.humidityLabel,
    required this.friends,
    required this.plants,
  });

  final PlaceDetailRole role;
  final String name;
  final String address;
  final String sunlightLabel;
  final String humidityLabel;
  final List<_PlaceFriend> friends;
  final List<_PlacePlant> plants;

  _PlaceDetailData applySummary(PlaceSummary summary) {
    return _PlaceDetailData(
      role: role,
      name: summary.name,
      address: summary.address ?? address,
      sunlightLabel: sunlightLabel,
      humidityLabel: humidityLabel,
      friends: friends,
      plants: plants,
    );
  }

  static _PlaceDetailData mock(String placeId, {PlaceDetailRole? role}) {
    final effectiveRole = role ?? _roleFromPlaceId(placeId);

    return _PlaceDetailData(
      role: effectiveRole,
      name: '스윗 홈_거실',
      address: '서울시 노원구 광운로 20',
      sunlightLabel: '9.3 / 5',
      humidityLabel: '69%',
      friends: const [
        _PlaceFriend(
          id: 'me',
          name: '나',
          imageAsset: AppImageAssets.placeDetailAvatarMe,
          isOwner: true,
        ),
        _PlaceFriend(
          id: 'common-mom',
          name: '커먼맘',
          imageAsset: AppImageAssets.placeDetailAvatarCommonMom,
        ),
        _PlaceFriend(id: 'common-papa', name: '커먼 파파'),
      ],
      plants: const [
        _PlacePlant(
          id: 'plant-1',
          name: '몬테',
          species: '몬스테라',
          description: '일주일에 x번 물주는 거 잊지 않기',
          dDayLabel: 'D-3',
          dateLabel: '2022.11.20',
          canWater: true,
        ),
        _PlacePlant(
          id: 'plant-2',
          name: '몬테',
          species: '몬스테라',
          description: '일주일에 x번 물주는 거 잊지 않기',
          dDayLabel: 'D-5',
          dateLabel: '2022.11.20',
        ),
        _PlacePlant(
          id: 'plant-3',
          name: '몬테',
          species: '몬스테라',
          description: '일주일에 x번 물주는 거 잊지 않기',
          dDayLabel: 'D-5',
          dateLabel: '2022.11.20',
        ),
        _PlacePlant(
          id: 'plant-4',
          name: '몬테',
          species: '몬스테라',
          description: '일주일에 x번 물주는 거 잊지 않기',
          dDayLabel: 'D-5',
          dateLabel: '2022.11.20',
        ),
      ],
    );
  }

  static PlaceDetailRole _roleFromPlaceId(String placeId) {
    final normalized = placeId.toLowerCase();

    if (normalized.contains('member') || normalized.contains('team')) {
      return PlaceDetailRole.member;
    }

    return PlaceDetailRole.leader;
  }
}

class _PlaceFriend {
  const _PlaceFriend({
    required this.id,
    required this.name,
    this.imageAsset,
    this.isOwner = false,
  });

  final String id;
  final String name;
  final String? imageAsset;
  final bool isOwner;

  PlaceFriendProfile toProfile() {
    return PlaceFriendProfile(id: id, name: name, imageAsset: imageAsset);
  }
}

class _PlacePlant {
  const _PlacePlant({
    required this.id,
    required this.name,
    required this.species,
    required this.description,
    required this.dDayLabel,
    required this.dateLabel,
    this.canWater = false,
  });

  final String id;
  final String name;
  final String species;
  final String description;
  final String dDayLabel;
  final String dateLabel;
  final bool canWater;
}

class _PlaceDetailHeader extends StatelessWidget {
  const _PlaceDetailHeader({required this.detail, required this.placeId});

  final _PlaceDetailData detail;
  final String placeId;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surfaceBase,
        boxShadow: [
          BoxShadow(
            color: AppColors.textStrong.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.x20,
          AppSpacing.x16,
          AppSpacing.x20,
          AppSpacing.x16,
        ),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _PlaceTitleBlock(
                    name: detail.name,
                    address: detail.address,
                  ),
                ),
                const SizedBox(width: AppSpacing.x12),
                _PlaceMetricStrip(
                  sunlightLabel: detail.sunlightLabel,
                  humidityLabel: detail.humidityLabel,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.x24),
            _PlaceFriendStrip(friends: detail.friends, placeId: placeId),
          ],
        ),
      ),
    );
  }
}

class _PlaceTitleBlock extends StatelessWidget {
  const _PlaceTitleBlock({required this.name, required this.address});

  final String name;
  final String address;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppTextStyles.size24Medium.copyWith(
            color: AppColors.textHeadline,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: AppSpacing.x4),
        Text(
          address,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppTextStyles.size16Medium.copyWith(
            color: AppColors.textStrong,
          ),
        ),
      ],
    );
  }
}

class _PlaceMetricStrip extends StatelessWidget {
  const _PlaceMetricStrip({
    required this.sunlightLabel,
    required this.humidityLabel,
  });

  final String sunlightLabel;
  final String humidityLabel;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _PlaceMetric(
          icon: AppIconAssets.tagSunlight,
          label: sunlightLabel,
          semanticsLabel: '햇빛',
        ),
        const SizedBox(width: AppSpacing.x16),
        _PlaceMetric(
          icon: AppIconAssets.tagHumidity,
          label: humidityLabel,
          semanticsLabel: '습도',
        ),
      ],
    );
  }
}

class _PlaceMetric extends StatelessWidget {
  const _PlaceMetric({
    required this.icon,
    required this.label,
    required this.semanticsLabel,
  });

  final String icon;
  final String label;
  final String semanticsLabel;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        CommonSvgIcon(
          icon,
          width: AppSizes.iconMedium,
          height: AppSizes.iconMedium,
          semanticsLabel: semanticsLabel,
        ),
        const SizedBox(height: AppSpacing.x8),
        Text(
          label,
          style: AppTextStyles.size14Medium.copyWith(
            color: AppColors.textHeadline,
          ),
        ),
      ],
    );
  }
}

class _PlaceFriendStrip extends StatelessWidget {
  const _PlaceFriendStrip({required this.friends, required this.placeId});

  final List<_PlaceFriend> friends;
  final String placeId;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        for (final friend in friends)
          _PlaceFriendMark(friend: friend, profile: friend.toProfile()),
        _FriendManagementShortcut(
          onPressed: () =>
              context.push(AppRoutePaths.friendManagementLocation(placeId)),
        ),
      ],
    );
  }
}

class _PlaceFriendMark extends StatelessWidget {
  const _PlaceFriendMark({required this.friend, required this.profile});

  final _PlaceFriend friend;
  final PlaceFriendProfile profile;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 56,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 46,
            height: 40,
            child: Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.center,
              children: [
                if (friend.isOwner)
                  Positioned(
                    left: 1,
                    top: 2,
                    child: Transform.rotate(
                      angle: -0.8,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: AppColors.brandSoft,
                          borderRadius: BorderRadius.circular(AppRadius.xSmall),
                        ),
                        child: const SizedBox(width: 18, height: 10),
                      ),
                    ),
                  ),
                PlaceFriendAvatar(friend: profile, dimension: 36),
              ],
            ),
          ),
          Text(
            friend.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: AppTextStyles.size12Medium.copyWith(
              color: AppColors.iconInactive,
            ),
          ),
        ],
      ),
    );
  }
}

class _FriendManagementShortcut extends StatelessWidget {
  const _FriendManagementShortcut({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: '친구 관리',
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onPressed,
        child: SizedBox(
          width: 56,
          height: 56,
          child: Align(
            alignment: Alignment.topCenter,
            child: DecoratedBox(
              decoration: const BoxDecoration(
                color: AppColors.surfaceDisabled,
                shape: BoxShape.circle,
              ),
              child: SizedBox.square(
                dimension: 36,
                child: Icon(
                  Icons.chevron_right,
                  color: AppColors.iconInactive,
                  size: AppSizes.iconMedium,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PlacePlantList extends StatelessWidget {
  const _PlacePlantList({required this.placeId, required this.plants});

  final String placeId;
  final List<_PlacePlant> plants;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.x20,
        AppSpacing.x24,
        AppSpacing.x20,
        120,
      ),
      child: Column(
        children: [
          for (final plant in plants) ...[
            CommonPlacePlantCard(
              width: double.infinity,
              name: plant.name,
              species: plant.species,
              description: plant.description,
              imageProvider: const AssetImage(
                AppImageAssets.placeDetailMonstera,
              ),
              action: CommonWateringButton(
                onPressed: plant.canWater ? () {} : null,
              ),
              trailing: _PlantDueInfo(
                dDayLabel: plant.dDayLabel,
                dateLabel: plant.dateLabel,
                isPrimary: plant.canWater,
              ),
              onTap: () => context.push(
                AppRoutePaths.plantDetailLocation(plant.id, placeId: placeId),
              ),
            ),
            if (plant != plants.last) const SizedBox(height: AppSpacing.x16),
          ],
        ],
      ),
    );
  }
}

class _PlantDueInfo extends StatelessWidget {
  const _PlantDueInfo({
    required this.dDayLabel,
    required this.dateLabel,
    required this.isPrimary,
  });

  final String dDayLabel;
  final String dateLabel;
  final bool isPrimary;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          dDayLabel,
          style: AppTextStyles.size16Bold.copyWith(
            color: isPrimary ? AppColors.brandPrimary : AppColors.iconInactive,
          ),
        ),
        Text(
          dateLabel,
          style: AppTextStyles.size12Medium.copyWith(color: AppColors.textBody),
        ),
      ],
    );
  }
}

class _PlaceDetailFab extends StatelessWidget {
  const _PlaceDetailFab({
    required this.placeId,
    required this.role,
    required this.onExit,
  });

  final String placeId;
  final PlaceDetailRole role;
  final VoidCallback onExit;

  @override
  Widget build(BuildContext context) {
    return CommonFabDial(
      actions: [
        CommonFabDialAction(
          label: '식물 추가하기',
          icon: const CommonSvgIcon(
            AppIconAssets.addPlant,
            width: AppSizes.iconMedium,
            height: AppSizes.iconMedium,
            color: AppColors.textStrong,
            semanticsLabel: '식물 추가',
          ),
          onPressed: () => context.push(AppRoutePaths.plantSearch),
        ),
        if (role == PlaceDetailRole.leader)
          CommonFabDialAction(
            label: '장소 수정하기',
            icon: const CommonSvgIcon(
              AppIconAssets.edit,
              width: AppSizes.iconMedium,
              height: AppSizes.iconMedium,
              color: AppColors.textStrong,
              semanticsLabel: '장소 수정',
            ),
            onPressed: () =>
                context.push(AppRoutePaths.placeEditLocation(placeId)),
          ),
        CommonFabDialAction(
          label: '장소 나가기',
          icon: const CommonSvgIcon(
            AppIconAssets.exit,
            width: AppSizes.iconMedium,
            height: AppSizes.iconMedium,
            color: AppColors.textStrong,
            semanticsLabel: '장소 나가기',
          ),
          onPressed: onExit,
        ),
      ],
      child: const CommonSvgIcon(
        AppIconAssets.shape,
        width: 5,
        height: 25,
        semanticsLabel: '장소 상세 메뉴',
      ),
    );
  }
}
