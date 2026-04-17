import 'package:commonplant_frontend/core/assets/app_icon_assets.dart';
import 'package:commonplant_frontend/core/theme/app_sizes.dart';
import 'package:commonplant_frontend/core/theme/app_spacing.dart';
import 'package:commonplant_frontend/core/theme/app_theme_tokens.dart';
import 'package:commonplant_frontend/shared/widgets/common_add_tile.dart';
import 'package:commonplant_frontend/shared/widgets/common_address_or_place_field.dart';
import 'package:commonplant_frontend/shared/widgets/common_button.dart';
import 'package:commonplant_frontend/shared/widgets/common_circle_image_box.dart';
import 'package:commonplant_frontend/shared/widgets/common_dialog.dart';
import 'package:commonplant_frontend/shared/widgets/common_edit_delete_popup.dart';
import 'package:commonplant_frontend/shared/widgets/common_fab.dart';
import 'package:commonplant_frontend/shared/widgets/common_memo_card.dart';
import 'package:commonplant_frontend/shared/widgets/common_photo_add_button.dart';
import 'package:commonplant_frontend/shared/widgets/common_place_card.dart';
import 'package:commonplant_frontend/shared/widgets/common_place_guide_banner.dart';
import 'package:commonplant_frontend/shared/widgets/common_place_image_add_button.dart';
import 'package:commonplant_frontend/shared/widgets/common_plant_card.dart';
import 'package:commonplant_frontend/shared/widgets/common_plus_icon_button.dart';
import 'package:commonplant_frontend/shared/widgets/common_scaffold.dart';
import 'package:commonplant_frontend/shared/widgets/common_search_text_field.dart';
import 'package:commonplant_frontend/shared/widgets/common_section_header.dart';
import 'package:commonplant_frontend/shared/widgets/common_svg_icon.dart';
import 'package:commonplant_frontend/shared/widgets/common_text_field.dart';
import 'package:commonplant_frontend/shared/widgets/common_watering_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final homeMessageProvider = Provider<String>(
  (ref) => '피그마 이미지 기준으로 버튼, 추가 타일, 메모 카드 스타일을 다시 맞추고 있습니다.',
);

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final TextEditingController _nicknameController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _nicknameFocusNode = FocusNode();
  final Set<String> _unavailableNicknames = const {'커먼플랜트'};
  String? _selectedAddress;

  CommonTextFieldValidation _validateNickname(String value, bool isFocused) {
    final nickname = value.trim();

    if (nickname.isEmpty) {
      return const CommonTextFieldValidation(
        state: CommonTextFieldState.normal,
      );
    }

    if (nickname.length < 2 || nickname.length > 10) {
      return const CommonTextFieldValidation(
        state: CommonTextFieldState.error,
        helperText: '2~10자의 닉네임으로 입력해주세요',
      );
    }

    if (isFocused) {
      return const CommonTextFieldValidation(
        state: CommonTextFieldState.normal,
      );
    }

    if (_unavailableNicknames.contains(nickname)) {
      return const CommonTextFieldValidation(
        state: CommonTextFieldState.error,
        helperText: '중복된 닉네임입니다',
      );
    }

    return const CommonTextFieldValidation(
      state: CommonTextFieldState.success,
      helperText: '사용가능한 닉네임 입니다',
    );
  }

  @override
  void dispose() {
    _nicknameFocusNode.dispose();
    _nicknameController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final tokens =
        Theme.of(context).extension<AppThemeTokens>() ?? AppThemeTokens.light;
    final message = ref.watch(homeMessageProvider);
    void noop() {}
    void selectSampleAddress() {
      setState(() {
        _selectedAddress = '서울시 노원구 광운로 20';
      });
    }

    void clearSampleAddress() {
      setState(() {
        _selectedAddress = null;
      });
    }

    void closeModal() => Navigator.of(context, rootNavigator: true).pop();
    void showDeleteDialog() {
      showCommonDialog<void>(
        context: context,
        child: CommonDialogCard(
          title: '커먼 파파',
          message: '님을 친구 목록에서 삭제하시겠습니까?',
          actions: [
            CommonDialogActionButton(
              label: '취소',
              foregroundColor: tokens.textBody,
              onPressed: closeModal,
            ),
            CommonDialogActionButton.confirm(
              label: '삭제',
              foregroundColor: tokens.brandStrong,
              onPressed: closeModal,
            ),
          ],
        ),
      );
    }

    void showEditDeletePopup() {
      showDialog<void>(
        context: context,
        barrierColor: commonDialogBarrierColor,
        barrierDismissible: true,
        builder: (dialogContext) {
          void closePopup() => Navigator.of(dialogContext).pop();

          return Stack(
            children: [
              Positioned(
                top: 136,
                right: 20,
                child: CommonEditDeletePopup(
                  onEdit: closePopup,
                  onDelete: closePopup,
                ),
              ),
            ],
          );
        },
      );
    }

    return CommonScaffold(
      title: 'CommonPlant Components',
      subtitle: '실제 피그마 캡처와 최대한 비슷하게 맞춘 컴포넌트 샘플',
      floatingActionButton: CommonFabDial(
        actions: [
          CommonFabDialAction(
            label: '식물 추가',
            icon: const CommonSvgIcon(
              AppIconAssets.plant,
              width: 20,
              height: 20,
              semanticsLabel: '식물',
            ),
            onPressed: noop,
          ),
          CommonFabDialAction(
            label: '장소 추가',
            icon: const CommonSvgIcon(
              AppIconAssets.edit,
              width: 20,
              height: 20,
              semanticsLabel: '수정',
            ),
            onPressed: noop,
          ),
        ],
        child: const CommonSvgIcon(
          AppIconAssets.shape,
          width: 5,
          height: 25,
          semanticsLabel: 'FAB 메뉴',
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(message, style: textTheme.bodyLarge),
          const SizedBox(height: AppSpacing.x24),
          const CommonSectionHeader(title: 'Buttons'),
          const SizedBox(height: AppSpacing.x12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CommonButton(
                label: '요청 3건',
                onPressed: noop,
                size: CommonButtonSize.small,
                backgroundColor: tokens.brandStrong,
                foregroundColor: tokens.onBrand,
              ),
              const SizedBox(height: AppSpacing.x12),
              Row(
                children: [
                  Expanded(
                    child: CommonButton(
                      label: '등록',
                      onPressed: noop,
                      size: CommonButtonSize.medium,
                      backgroundColor: tokens.brandStrong,
                      foregroundColor: tokens.onBrand,
                    ),
                  ),
                  Expanded(
                    child: CommonButton(
                      label: '취소',
                      onPressed: noop,
                      size: CommonButtonSize.medium,
                      backgroundColor: tokens.textStrong,
                      foregroundColor: tokens.onBrand,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.x12),
              CommonButton(
                label: '완료',
                onPressed: noop,
                size: CommonButtonSize.large,
                backgroundColor: tokens.brandStrong,
                foregroundColor: tokens.onBrand,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.x24),
          const CommonSectionHeader(title: 'Fields'),
          const SizedBox(height: AppSpacing.x12),
          const CommonCircleImageBox(),
          const SizedBox(height: AppSpacing.x16),
          const CommonPhotoAddButton(),
          const SizedBox(height: AppSpacing.x16),
          const CommonPlaceImageAddButton(),
          const SizedBox(height: AppSpacing.x16),
          CommonTextField(
            controller: _nicknameController,
            focusNode: _nicknameFocusNode,
            hintText: '닉네임을 입력해 주세요',
            maxLength: 10,
            validator: _validateNickname,
          ),
          const SizedBox(height: AppSpacing.x16),
          CommonAddressOrPlaceField(
            label: '주소',
            value: _selectedAddress,
            onTap: selectSampleAddress,
            onClear: clearSampleAddress,
          ),
          const SizedBox(height: AppSpacing.x16),
          CommonSearchTextField(
            controller: _searchController,
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: AppSpacing.x24),
          const CommonSectionHeader(title: 'Add Tiles'),
          const SizedBox(height: AppSpacing.x12),
          const Align(
            alignment: Alignment.centerLeft,
            child: CommonPlusIconButton(),
          ),
          const SizedBox(height: AppSpacing.x16),
          const SizedBox(
            width: AppSizes.placeAddTileWidth,
            height: AppSizes.placeAddTileHeight,
            child: CommonAddTile(
              label: '장소 추가하기',
              variant: CommonAddTileVariant.place,
              width: AppSizes.placeAddTileWidth,
              height: AppSizes.placeAddTileHeight,
            ),
          ),
          const SizedBox(height: AppSpacing.x16),
          const Align(
            alignment: Alignment.centerLeft,
            child: SizedBox(
              width: AppSizes.plantAddTileWidth,
              child: CommonAddTile(
                label: '식물 추가하기',
                variant: CommonAddTileVariant.plantDisabled,
                enabled: false,
                width: AppSizes.plantAddTileWidth,
                height: AppSizes.plantAddTileHeight,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.x16),
          const CommonPlaceGuideBanner(label: '가나다라마바사아자차'),
          const SizedBox(height: AppSpacing.x24),
          const CommonSectionHeader(title: 'Cards'),
          const SizedBox(height: AppSpacing.x12),
          const CommonPlaceCard(title: '스윗 홈_거실'),
          const SizedBox(height: AppSpacing.x16),
          const CommonPlantCard(),
          const SizedBox(height: AppSpacing.x16),
          CommonPlacePlantCard(
            name: '몬테',
            species: '몬스테라',
            description: '일주일에 x번 물주는 거 잊지 않기',
            action: const CommonWateringButton(),
            dDayLabel: 'D-3',
            dateLabel: '2022.11.20',
          ),
          const SizedBox(height: AppSpacing.x16),
          CommonMemoCard(
            author: '커먼플랜트',
            content: '장마여서 물주는 날짜를 조금 늦춤 하지만 해는 말구나 몬테랑 함께...',
            dateLabel: '2022.11.20',
            avatar: Container(
              width: AppSizes.memoAvatarSize,
              height: AppSizes.memoAvatarSize,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [Color(0xFFB7D9D5), Color(0xFF6D8B9B)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
            thumbnail: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: const LinearGradient(
                  colors: [Color(0xFF9EC38E), Color(0xFF355E3B)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.x24),
          const CommonSectionHeader(title: 'Dialog'),
          const SizedBox(height: AppSpacing.x12),
          CommonButton(
            label: '삭제 다이얼로그 보기',
            onPressed: showDeleteDialog,
            size: CommonButtonSize.large,
            backgroundColor: tokens.brandStrong,
            foregroundColor: tokens.onBrand,
          ),
          const SizedBox(height: AppSpacing.x16),
          CommonButton(
            label: '수정/삭제 팝업 보기',
            onPressed: showEditDeletePopup,
            size: CommonButtonSize.large,
            backgroundColor: tokens.textStrong,
            foregroundColor: tokens.onBrand,
          ),
        ],
      ),
    );
  }
}
