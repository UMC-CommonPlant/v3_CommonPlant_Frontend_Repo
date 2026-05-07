import 'package:commonplant_frontend/app/router/route_paths.dart';
import 'package:commonplant_frontend/core/theme/app_colors.dart';
import 'package:commonplant_frontend/core/theme/app_spacing.dart';
import 'package:commonplant_frontend/core/theme/app_text_styles.dart';
import 'package:commonplant_frontend/features/common/presentation/widgets/phase0_widgets.dart';
import 'package:commonplant_frontend/features/place/presentation/providers/place_list_provider.dart';
import 'package:commonplant_frontend/shared/widgets/common_address_or_place_field.dart';
import 'package:commonplant_frontend/shared/widgets/common_button.dart';
import 'package:commonplant_frontend/shared/widgets/common_place_image_add_button.dart';
import 'package:commonplant_frontend/shared/widgets/common_scaffold.dart';
import 'package:commonplant_frontend/shared/widgets/common_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class PlaceFormPage extends ConsumerStatefulWidget {
  const PlaceFormPage({super.key, this.placeId});

  final String? placeId;

  bool get isEdit => placeId != null;

  @override
  ConsumerState<PlaceFormPage> createState() => _PlaceFormPageState();
}

class _PlaceFormPageState extends ConsumerState<PlaceFormPage> {
  late final TextEditingController _nameController;
  String? _address;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(
      text: widget.isEdit ? '우리집 거실' : '',
    );
    _address = widget.isEdit ? '서울시 노원구 광운로 20' : null;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final canSubmit = _nameController.text.trim().isNotEmpty;

    return CommonScaffold(
      title: widget.isEdit ? '장소 수정' : '장소 등록',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(child: CommonPlaceImageAddButton(onTap: () {})),
          const SizedBox(height: AppSpacing.x32),
          Text(
            '장소 이름',
            style: AppTextStyles.size16Bold.copyWith(
              color: AppColors.textStrong,
            ),
          ),
          const SizedBox(height: AppSpacing.x8),
          CommonTextField(
            controller: _nameController,
            hintText: '장소 이름을 입력해 주세요',
            maxLength: 20,
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: AppSpacing.x24),
          CommonAddressOrPlaceField(
            label: '주소',
            value: _address,
            onTap: () => context.push(AppRoutePaths.addressSearch),
            onClear: () => setState(() => _address = null),
          ),
          const SizedBox(height: AppSpacing.x24),
          Phase0Section(
            title: '함께 관리할 친구',
            subtitle: widget.isEdit
                ? '친구 관리는 상세 화면에서도 변경할 수 있어요.'
                : '초대할 친구를 먼저 골라도 좋아요.',
            child: Phase0Surface(
              onTap: () => context.push(AppRoutePaths.placeFriendAdd),
              child: Row(
                children: [
                  const Phase0UserAvatar(label: '파'),
                  const SizedBox(width: AppSpacing.x12),
                  Expanded(
                    child: Text(
                      widget.isEdit ? '커먼 파파 외 2명' : '친구 추가하기',
                      style: AppTextStyles.size16Medium.copyWith(
                        color: AppColors.textStrong,
                      ),
                    ),
                  ),
                  const Icon(Icons.chevron_right, color: AppColors.textStrong),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.x32),
          CommonButton(
            label: widget.isEdit ? '저장' : '등록',
            onPressed: canSubmit ? _submit : null,
          ),
        ],
      ),
    );
  }

  void _submit() {
    final name = _nameController.text.trim();
    final notifier = ref.read(placeListProvider.notifier);

    if (widget.placeId case final placeId?) {
      notifier.updatePlace(id: placeId, name: name, address: _address);
    } else {
      notifier.addPlace(name: name, address: _address);
    }

    context.go(AppRoutePaths.home);
  }
}
