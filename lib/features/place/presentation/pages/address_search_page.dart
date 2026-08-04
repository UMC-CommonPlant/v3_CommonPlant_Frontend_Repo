import 'package:commonplant_frontend/core/theme/app_colors.dart';
import 'package:commonplant_frontend/core/theme/app_radius.dart';
import 'package:commonplant_frontend/core/theme/app_sizes.dart';
import 'package:commonplant_frontend/core/theme/app_spacing.dart';
import 'package:commonplant_frontend/core/theme/app_text_styles.dart';
import 'package:commonplant_frontend/features/place/presentation/models/address_search_result.dart';
import 'package:commonplant_frontend/features/place/presentation/providers/address_search_controller.dart';
import 'package:commonplant_frontend/features/place/presentation/widgets/address_search_field.dart';
import 'package:commonplant_frontend/shared/widgets/common_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

const double _addressSearchResultHeight = 72;
const double _addressSearchResultGap = 4;
const double _addressSearchButtonWidth = 73;
const double _addressSearchButtonHeight = 36;
const double _addressSearchResultVerticalPadding = AppSpacing.x10;
const double _addressSearchResultTextWidth = 219;

class AddressSearchPage extends ConsumerWidget {
  const AddressSearchPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final searchState = ref.watch(addressSearchControllerProvider);

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
            AddressSearchField(
              initialQuery: searchState.query,
              onChanged: ref
                  .read(addressSearchControllerProvider.notifier)
                  .updateQuery,
            ),
            const SizedBox(height: _addressSearchResultGap),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.only(
                  bottom: AppSpacing.x40 + AppSizes.navigationBarHeight,
                ),
                itemCount: searchState.results.length,
                separatorBuilder: (_, _) =>
                    const SizedBox(height: _addressSearchResultGap),
                itemBuilder: (context, index) {
                  final result = searchState.results[index];

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

  final AddressSearchResult result;
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
            vertical: _addressSearchResultVerticalPadding,
          ),
          child: Row(
            children: [
              SizedBox(
                width: _addressSearchResultTextWidth,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
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

  final AddressSearchResult result;

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
