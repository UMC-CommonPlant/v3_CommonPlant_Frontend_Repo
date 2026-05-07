import 'package:commonplant_frontend/core/theme/app_colors.dart';
import 'package:commonplant_frontend/core/theme/app_spacing.dart';
import 'package:commonplant_frontend/core/theme/app_text_styles.dart';
import 'package:commonplant_frontend/features/common/presentation/widgets/phase0_widgets.dart';
import 'package:commonplant_frontend/shared/widgets/common_button.dart';
import 'package:commonplant_frontend/shared/widgets/common_dialog.dart';
import 'package:commonplant_frontend/shared/widgets/common_scaffold.dart';
import 'package:commonplant_frontend/shared/widgets/common_search_text_field.dart';
import 'package:flutter/material.dart';

class FriendManagementPage extends StatefulWidget {
  const FriendManagementPage({super.key, required this.placeId});

  final String placeId;

  @override
  State<FriendManagementPage> createState() => _FriendManagementPageState();
}

class _FriendManagementPageState extends State<FriendManagementPage> {
  final TextEditingController _searchController = TextEditingController();
  final List<_PlaceMember> _members = [
    const _PlaceMember(name: '커먼 파파', role: '리더'),
    const _PlaceMember(name: '초록이', role: '팀원'),
    const _PlaceMember(name: '식집사', role: '팀원'),
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showDeleteDialog(_PlaceMember member) {
    showCommonDialog<void>(
      context: context,
      child: CommonDialogCard(
        title: member.name,
        message: '님을 친구 목록에서 삭제하시겠습니까?',
        actions: [
          CommonDialogActionButton(
            label: '취소',
            foregroundColor: AppColors.textBody,
            onPressed: () => Navigator.of(context).pop(),
          ),
          CommonDialogActionButton.confirm(
            label: '삭제',
            foregroundColor: AppColors.danger,
            onPressed: () {
              setState(() => _members.remove(member));
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final query = _searchController.text.trim();
    final results = query.isEmpty
        ? _members
        : _members.where((member) => member.name.contains(query)).toList();

    return CommonScaffold(
      title: '친구 관리',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          CommonSearchTextField(
            controller: _searchController,
            hintText: '친구 닉네임을 입력해 주세요.',
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: AppSpacing.x24),
          for (final member in results) ...[
            Phase0Surface(
              child: Row(
                children: [
                  Phase0UserAvatar(label: member.name.characters.first),
                  const SizedBox(width: AppSpacing.x12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          member.name,
                          style: AppTextStyles.size16Bold.copyWith(
                            color: AppColors.textStrong,
                          ),
                        ),
                        Text(
                          member.role,
                          style: AppTextStyles.size14Medium.copyWith(
                            color: member.role == '리더'
                                ? AppColors.brandStrong
                                : AppColors.textBody,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (member.role != '리더')
                    CommonButton.text(
                      label: '삭제',
                      size: CommonButtonSize.medium,
                      foregroundColor: AppColors.danger,
                      onPressed: () => _showDeleteDialog(member),
                    ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.x12),
          ],
          const SizedBox(height: AppSpacing.x16),
          CommonButton(
            label: '친구 추가',
            onPressed: () => Navigator.of(context).maybePop(),
          ),
        ],
      ),
    );
  }
}

class _PlaceMember {
  const _PlaceMember({required this.name, required this.role});

  final String name;
  final String role;
}
