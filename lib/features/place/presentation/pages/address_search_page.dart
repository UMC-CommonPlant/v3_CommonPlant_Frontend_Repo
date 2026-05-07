import 'package:commonplant_frontend/core/assets/app_icon_assets.dart';
import 'package:commonplant_frontend/core/theme/app_colors.dart';
import 'package:commonplant_frontend/core/theme/app_spacing.dart';
import 'package:commonplant_frontend/core/theme/app_text_styles.dart';
import 'package:commonplant_frontend/features/common/presentation/widgets/phase0_widgets.dart';
import 'package:commonplant_frontend/shared/widgets/common_scaffold.dart';
import 'package:commonplant_frontend/shared/widgets/common_search_text_field.dart';
import 'package:commonplant_frontend/shared/widgets/common_svg_icon.dart';
import 'package:flutter/material.dart';

class AddressSearchPage extends StatefulWidget {
  const AddressSearchPage({super.key});

  @override
  State<AddressSearchPage> createState() => _AddressSearchPageState();
}

class _AddressSearchPageState extends State<AddressSearchPage> {
  final TextEditingController _searchController = TextEditingController();

  static const List<String> _addresses = [
    '서울시 노원구 광운로 20',
    '서울시 성동구 연무장길 12',
    '서울시 마포구 월드컵북로 10',
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final query = _searchController.text.trim();
    final results = query.isEmpty
        ? _addresses
        : _addresses.where((address) => address.contains(query)).toList();

    return CommonScaffold(
      title: '주소 검색',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          CommonSearchTextField(
            controller: _searchController,
            hintText: '주소를 입력해 주세요.',
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: AppSpacing.x24),
          if (results.isEmpty)
            const Phase0EmptyState(
              title: '검색 결과가 없어요',
              description: '도로명이나 건물명을 다시 입력해 주세요.',
              icon: CommonSvgIcon(
                AppIconAssets.placeEmpty,
                height: 72,
                semanticsLabel: '주소 없음',
              ),
            )
          else
            for (final address in results) ...[
              Phase0Surface(
                onTap: () => Navigator.of(context).maybePop(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      address,
                      style: AppTextStyles.size16Bold.copyWith(
                        color: AppColors.textStrong,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.x4),
                    Text(
                      '건물명 · 커먼플랜트 샘플 주소',
                      style: AppTextStyles.size14Medium.copyWith(
                        color: AppColors.textBody,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.x12),
            ],
        ],
      ),
    );
  }
}
