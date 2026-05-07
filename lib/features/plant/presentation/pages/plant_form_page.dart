import 'package:commonplant_frontend/app/router/route_paths.dart';
import 'package:commonplant_frontend/core/theme/app_colors.dart';
import 'package:commonplant_frontend/core/theme/app_spacing.dart';
import 'package:commonplant_frontend/core/theme/app_text_styles.dart';
import 'package:commonplant_frontend/features/common/presentation/widgets/phase0_widgets.dart';
import 'package:commonplant_frontend/features/plant/presentation/providers/plant_list_provider.dart';
import 'package:commonplant_frontend/shared/widgets/common_address_or_place_field.dart';
import 'package:commonplant_frontend/shared/widgets/common_button.dart';
import 'package:commonplant_frontend/shared/widgets/common_photo_add_button.dart';
import 'package:commonplant_frontend/shared/widgets/common_scaffold.dart';
import 'package:commonplant_frontend/shared/widgets/common_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class PlantFormPage extends ConsumerStatefulWidget {
  const PlantFormPage({super.key, this.plantId});

  final String? plantId;

  bool get isEdit => plantId != null;

  @override
  ConsumerState<PlantFormPage> createState() => _PlantFormPageState();
}

class _PlantFormPageState extends ConsumerState<PlantFormPage> {
  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;
  String? _place;
  String? _wateringDate;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.isEdit ? '몬스테라' : '');
    _descriptionController = TextEditingController(
      text: widget.isEdit ? '거실 창가 오른쪽에서 키우는 중' : '',
    );
    _place = widget.isEdit ? '우리집 거실' : null;
    _wateringDate = widget.isEdit ? '2026.05.05' : null;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final canSubmit = _nameController.text.trim().isNotEmpty && _place != null;

    return CommonScaffold(
      title: widget.isEdit ? '식물 수정' : '식물 등록',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              CommonPhotoAddButton(currentCount: widget.isEdit ? 1 : 0),
              const SizedBox(width: AppSpacing.x16),
              Expanded(
                child: Text(
                  '식물 사진은 최대 5장까지 추가할 수 있어요.',
                  style: AppTextStyles.size14Medium.copyWith(
                    color: AppColors.textBody,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.x32),
          Text(
            '식물 이름',
            style: AppTextStyles.size16Bold.copyWith(
              color: AppColors.textStrong,
            ),
          ),
          const SizedBox(height: AppSpacing.x8),
          CommonTextField(
            controller: _nameController,
            hintText: '식물 이름을 입력해 주세요',
            maxLength: 20,
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: AppSpacing.x24),
          CommonAddressOrPlaceField(
            label: '장소',
            value: _place,
            onTap: () => setState(() => _place = '우리집 거실'),
            onClear: () => setState(() => _place = null),
          ),
          const SizedBox(height: AppSpacing.x8),
          CommonAddressOrPlaceField(
            label: '마지막 물준 날',
            value: _wateringDate,
            onTap: () => setState(() => _wateringDate = '2026.05.06'),
            onClear: () => setState(() => _wateringDate = null),
          ),
          const SizedBox(height: AppSpacing.x24),
          Text(
            '메모',
            style: AppTextStyles.size16Bold.copyWith(
              color: AppColors.textStrong,
            ),
          ),
          const SizedBox(height: AppSpacing.x8),
          CommonTextField(
            controller: _descriptionController,
            hintText: '관리 위치나 특징을 입력해 주세요',
            maxLength: 40,
          ),
          const SizedBox(height: AppSpacing.x24),
          Phase0Section(
            title: '관리 태그',
            child: const Wrap(
              spacing: AppSpacing.x8,
              runSpacing: AppSpacing.x8,
              children: [
                Phase0Chip(label: '공기정화', isActive: true),
                Phase0Chip(label: '초보자 추천', isActive: true),
                Phase0Chip(label: '간접광'),
              ],
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
    final description = _descriptionController.text.trim();

    if (widget.isEdit) {
      ref
          .read(plantListProvider.notifier)
          .updatePlant(
            id: widget.plantId!,
            name: name,
            placeName: _place,
            description: description.isEmpty ? null : description,
          );
      context.go(AppRoutePaths.plantDetailLocation(widget.plantId!));
      return;
    }

    ref
        .read(plantListProvider.notifier)
        .addPlant(
          name: name,
          placeName: _place,
          description: description.isEmpty ? null : description,
        );
    context.go(AppRoutePaths.home);
  }
}
