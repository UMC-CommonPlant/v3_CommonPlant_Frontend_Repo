import 'package:commonplant_frontend/core/theme/app_colors.dart';
import 'package:commonplant_frontend/core/theme/app_radius.dart';
import 'package:commonplant_frontend/core/theme/app_sizes.dart';
import 'package:commonplant_frontend/core/theme/app_spacing.dart';
import 'package:commonplant_frontend/core/theme/app_text_styles.dart';
import 'package:commonplant_frontend/shared/widgets/common_scaffold.dart';
import 'package:commonplant_frontend/shared/widgets/common_search_text_field.dart';
import 'package:flutter/material.dart';

const double _addressSearchResultHeight = 72;
const double _addressSearchResultGap = 4;
const double _addressSearchButtonWidth = 73;
const double _addressSearchButtonHeight = 36;
const double _addressSearchResultTextWidth = 219;

class AddressSearchPage extends StatefulWidget {
  const AddressSearchPage({super.key});

  @override
  State<AddressSearchPage> createState() => _AddressSearchPageState();
}

class _AddressSearchPageState extends State<AddressSearchPage> {
  final TextEditingController _searchController = TextEditingController(
    text: '신도림역',
  );

  static const List<_AddressSearchResult> _addresses = [
    _AddressSearchResult(
      titlePrefix: '신도림역',
      titleSuffix: '1호선',
      address: '서울 구로구 경인로 688',
    ),
    _AddressSearchResult(
      titlePrefix: '신도림역',
      titleSuffix: '2호선',
      address: '서울 구로구 새말로 지하 117-21',
      highlighted: true,
    ),
    _AddressSearchResult(
      titlePrefix: '신도림역',
      titleSuffix: '2호선',
      address: '서울 구로구 새말로 지하 117-21',
    ),
    _AddressSearchResult(
      titlePrefix: '신도림역',
      titleSuffix: '2호선',
      address: '서울 구로구 새말로 지하 117-21',
    ),
    _AddressSearchResult(
      titlePrefix: '신도림역',
      titleSuffix: '2호선',
      address: '서울 구로구 새말로 지하 117-21',
    ),
    _AddressSearchResult(
      titlePrefix: '신도림역',
      titleSuffix: '2호선',
      address: '서울 구로구 새말로 지하 117-21',
    ),
    _AddressSearchResult(
      titlePrefix: '신도림역',
      titleSuffix: '2호선',
      address: '서울 구로구 새말로 지하 117-21',
    ),
    _AddressSearchResult(
      titlePrefix: '신도림역',
      titleSuffix: '2호선',
      address: '서울 구로구 새말로 지하 117-21',
    ),
    _AddressSearchResult(
      titlePrefix: '신도림역',
      titleSuffix: '2호선',
      address: '서울 구로구 새말로 지하 117-21',
    ),
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
        : _addresses
              .where(
                (result) =>
                    result.title.contains(query) ||
                    result.address.contains(query),
              )
              .toList();

    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Column(
          children: [
            CommonNavigationBar(
              title: '주소 검색',
              titleStyle: AppTextStyles.size18Medium.copyWith(
                color: AppColors.textStrong,
                fontWeight: FontWeight.w700,
              ),
            ),
            CommonSearchTextField(
              controller: _searchController,
              hintText: '주소를 입력해 주세요.',
              horizontalPadding: AppSpacing.x20,
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: _addressSearchResultGap),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.only(
                  bottom: AppSpacing.x40 + AppSizes.navigationBarHeight,
                ),
                itemCount: results.length,
                separatorBuilder: (_, _) =>
                    const SizedBox(height: _addressSearchResultGap),
                itemBuilder: (context, index) {
                  final result = results[index];

                  return _AddressSearchResultTile(
                    result: result,
                    onSelect: () => Navigator.of(context).maybePop(),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AddressSearchResultTile extends StatelessWidget {
  const _AddressSearchResultTile({
    required this.result,
    required this.onSelect,
  });

  final _AddressSearchResult result;
  final VoidCallback onSelect;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: result.highlighted ? AppColors.surfaceDisabled : AppColors.white,
      child: SizedBox(
        height: _addressSearchResultHeight,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.x20,
            vertical: AppSpacing.x12,
          ),
          child: Row(
            children: [
              SizedBox(
                width: _addressSearchResultTextWidth,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _AddressSearchResultTitle(result: result),
                    const SizedBox(height: AppSpacing.x4),
                    Text(
                      result.address,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.size14Medium.copyWith(
                        color: AppColors.textBody,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              _AddressSearchSelectButton(onPressed: onSelect),
            ],
          ),
        ),
      ),
    );
  }
}

class _AddressSearchResultTitle extends StatelessWidget {
  const _AddressSearchResultTitle({required this.result});

  final _AddressSearchResult result;

  @override
  Widget build(BuildContext context) {
    return Text.rich(
      TextSpan(
        children: [
          TextSpan(
            text: '${result.titlePrefix} ',
            style: AppTextStyles.size18Medium.copyWith(
              color: AppColors.brandStrong,
            ),
          ),
          TextSpan(
            text: result.titleSuffix,
            style: AppTextStyles.size18Medium.copyWith(
              color: AppColors.textHeadline,
            ),
          ),
        ],
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }
}

class _AddressSearchSelectButton extends StatelessWidget {
  const _AddressSearchSelectButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: _addressSearchButtonWidth,
      height: _addressSearchButtonHeight,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          backgroundColor: AppColors.white,
          foregroundColor: AppColors.textStrong,
          padding: EdgeInsets.zero,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          side: const BorderSide(color: AppColors.borderMuted),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.xSmall),
          ),
          textStyle: AppTextStyles.size14Medium,
        ),
        child: Text(
          '선택',
          style: AppTextStyles.size14Medium.copyWith(
            color: AppColors.textStrong,
          ),
        ),
      ),
    );
  }
}

class _AddressSearchResult {
  const _AddressSearchResult({
    required this.titlePrefix,
    required this.titleSuffix,
    required this.address,
    this.highlighted = false,
  });

  final String titlePrefix;
  final String titleSuffix;
  final String address;
  final bool highlighted;

  String get title => '$titlePrefix $titleSuffix';
}
