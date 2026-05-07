import 'package:commonplant_frontend/app/router/route_paths.dart';
import 'package:commonplant_frontend/core/assets/app_icon_assets.dart';
import 'package:commonplant_frontend/core/theme/app_colors.dart';
import 'package:commonplant_frontend/core/theme/app_spacing.dart';
import 'package:commonplant_frontend/features/common/presentation/widgets/phase0_widgets.dart';
import 'package:commonplant_frontend/shared/widgets/common_button.dart';
import 'package:commonplant_frontend/shared/widgets/common_dialog.dart';
import 'package:commonplant_frontend/shared/widgets/common_place_card.dart';
import 'package:commonplant_frontend/shared/widgets/common_place_guide_banner.dart';
import 'package:commonplant_frontend/shared/widgets/common_plant_card.dart';
import 'package:commonplant_frontend/shared/widgets/common_scaffold.dart';
import 'package:commonplant_frontend/shared/widgets/common_svg_icon.dart';
import 'package:commonplant_frontend/shared/widgets/common_watering_button.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class PlaceDetailPage extends StatelessWidget {
  const PlaceDetailPage({super.key, required this.placeId});

  final String placeId;

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
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CommonScaffold(
      title: '장소 상세',
      trailing: IconButton(
        onPressed: () => context.push(AppRoutePaths.placeEditLocation(placeId)),
        icon: const CommonSvgIcon(
          AppIconAssets.edit,
          width: 24,
          height: 24,
          semanticsLabel: '장소 수정',
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CommonPlaceCard(title: '우리집 거실', width: double.infinity, height: 188),
          const SizedBox(height: AppSpacing.x16),
          Wrap(
            spacing: AppSpacing.x8,
            runSpacing: AppSpacing.x8,
            children: const [
              Phase0Chip(label: '리더', isActive: true),
              Phase0Chip(label: '함께 관리 3명'),
              Phase0Chip(label: '식물 2개'),
            ],
          ),
          const SizedBox(height: AppSpacing.x20),
          const CommonPlaceGuideBanner(label: '내일 물주기가 필요한 식물이 있어요'),
          const SizedBox(height: AppSpacing.x32),
          Phase0Section(
            title: '장소 정보',
            child: const Phase0Surface(
              child: Column(
                children: [
                  Phase0InfoRow(label: '주소', value: '서울시 노원구 광운로 20'),
                  SizedBox(height: AppSpacing.x12),
                  Phase0InfoRow(label: '장소 ID', value: 'place-1'),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.x32),
          Phase0Section(
            title: '식물',
            trailing: TextButton(
              onPressed: () => context.push(AppRoutePaths.plantSearch),
              child: const Text('추가'),
            ),
            child: Column(
              children: [
                CommonPlacePlantCard(
                  name: '몬스테라',
                  species: 'Monstera deliciosa',
                  description: '거실 창가 오른쪽',
                  action: const CommonWateringButton(),
                  dDayLabel: 'D-1',
                  dateLabel: '다음 물주기',
                  onTap: () => context.push(
                    AppRoutePaths.plantDetailLocation('plant-1'),
                  ),
                ),
                const SizedBox(height: AppSpacing.x12),
                CommonPlacePlantCard(
                  name: '스투키',
                  species: 'Sansevieria stuckyi',
                  description: '소파 옆 선반',
                  action: const CommonWateringButton(),
                  dDayLabel: 'D-4',
                  dateLabel: '다음 물주기',
                  onTap: () => context.push(
                    AppRoutePaths.plantDetailLocation('plant-2'),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.x32),
          Phase0Section(
            title: '친구',
            trailing: TextButton(
              onPressed: () =>
                  context.push(AppRoutePaths.friendManagementLocation(placeId)),
              child: const Text('관리'),
            ),
            child: const Phase0Surface(
              child: Row(
                children: [
                  Phase0UserAvatar(label: '파'),
                  SizedBox(width: AppSpacing.x8),
                  Phase0UserAvatar(label: '초'),
                  SizedBox(width: AppSpacing.x8),
                  Phase0UserAvatar(label: '식'),
                  SizedBox(width: AppSpacing.x12),
                  Expanded(
                    child: Text(
                      '커먼 파파, 초록이, 식집사',
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.x32),
          CommonButton.secondary(
            label: '장소 나가기',
            foregroundColor: AppColors.danger,
            onPressed: () => _showExitDialog(context),
          ),
        ],
      ),
    );
  }
}
