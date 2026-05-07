import 'package:commonplant_frontend/app/router/route_paths.dart';
import 'package:commonplant_frontend/core/assets/app_icon_assets.dart';
import 'package:commonplant_frontend/core/theme/app_colors.dart';
import 'package:commonplant_frontend/core/theme/app_spacing.dart';
import 'package:commonplant_frontend/core/theme/app_text_styles.dart';
import 'package:commonplant_frontend/features/common/presentation/widgets/phase0_widgets.dart';
import 'package:commonplant_frontend/shared/widgets/common_button.dart';
import 'package:commonplant_frontend/shared/widgets/common_memo_card.dart';
import 'package:commonplant_frontend/shared/widgets/common_plant_card.dart';
import 'package:commonplant_frontend/shared/widgets/common_scaffold.dart';
import 'package:commonplant_frontend/shared/widgets/common_svg_icon.dart';
import 'package:commonplant_frontend/shared/widgets/common_watering_button.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class PlantDetailPage extends StatelessWidget {
  const PlantDetailPage({super.key, required this.plantId});

  final String plantId;

  @override
  Widget build(BuildContext context) {
    return CommonScaffold(
      title: '식물 상세',
      trailing: IconButton(
        onPressed: () => context.push(AppRoutePaths.plantEditLocation(plantId)),
        icon: const CommonSvgIcon(
          AppIconAssets.edit,
          width: 24,
          height: 24,
          semanticsLabel: '식물 수정',
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(child: CommonPlantCard(width: 220, height: 180)),
          const SizedBox(height: AppSpacing.x24),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '몬스테라',
                      style: AppTextStyles.size24Medium.copyWith(
                        color: AppColors.textHeadline,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.x4),
                    Text(
                      'Monstera deliciosa',
                      style: AppTextStyles.size14Medium.copyWith(
                        color: AppColors.textBody,
                      ),
                    ),
                  ],
                ),
              ),
              const CommonWateringButton(),
            ],
          ),
          const SizedBox(height: AppSpacing.x16),
          const Wrap(
            spacing: AppSpacing.x8,
            runSpacing: AppSpacing.x8,
            children: [
              Phase0Chip(label: 'D-1', isActive: true),
              Phase0Chip(label: '우리집 거실'),
              Phase0Chip(label: '초보자 추천'),
            ],
          ),
          const SizedBox(height: AppSpacing.x32),
          const Phase0Section(
            title: '관리 정보',
            child: Phase0Surface(
              child: Column(
                children: [
                  Phase0InfoRow(label: '장소', value: '우리집 거실'),
                  SizedBox(height: AppSpacing.x12),
                  Phase0InfoRow(label: '마지막 물주기', value: '2026.05.05'),
                  SizedBox(height: AppSpacing.x12),
                  Phase0InfoRow(label: '다음 물주기', value: '2026.05.07'),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.x32),
          Phase0Section(
            title: '메모',
            trailing: TextButton(
              onPressed: () =>
                  context.push(AppRoutePaths.memoListLocation(plantId)),
              child: const Text('전체보기'),
            ),
            child: SizedBox(
              height: 174,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: const [
                  CommonMemoCard(
                    author: '커먼 파파',
                    content: '새 잎이 올라오고 있어요.',
                    dateLabel: '2026.05.06',
                  ),
                  SizedBox(width: AppSpacing.x12),
                  CommonMemoCard(
                    author: '초록이',
                    content: '흙이 말라서 물을 조금 줬어요.',
                    dateLabel: '2026.05.05',
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.x24),
          CommonButton(
            label: '메모 작성',
            onPressed: () =>
                context.push(AppRoutePaths.memoWriteLocation(plantId)),
          ),
        ],
      ),
    );
  }
}
