import 'package:commonplant_frontend/app/router/route_paths.dart';
import 'package:commonplant_frontend/core/theme/app_colors.dart';
import 'package:commonplant_frontend/core/theme/app_spacing.dart';
import 'package:commonplant_frontend/core/theme/app_text_styles.dart';
import 'package:commonplant_frontend/features/common/presentation/widgets/phase0_widgets.dart';
import 'package:commonplant_frontend/shared/widgets/common_button.dart';
import 'package:commonplant_frontend/shared/widgets/common_scaffold.dart';
import 'package:commonplant_frontend/shared/widgets/common_search_text_field.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class PlaceFriendAddPage extends StatefulWidget {
  const PlaceFriendAddPage({super.key});

  @override
  State<PlaceFriendAddPage> createState() => _PlaceFriendAddPageState();
}

class _PlaceFriendAddPageState extends State<PlaceFriendAddPage> {
  final TextEditingController _searchController = TextEditingController();
  final Set<String> _selectedIds = <String>{'friend-1'};

  static const List<_FriendCandidate> _friends = [
    _FriendCandidate(id: 'friend-1', name: '커먼 파파', email: 'papa@common.plant'),
    _FriendCandidate(id: 'friend-2', name: '초록이', email: 'green@common.plant'),
    _FriendCandidate(id: 'friend-3', name: '식집사', email: 'plant@common.plant'),
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _toggle(String id) {
    setState(() {
      if (_selectedIds.contains(id)) {
        _selectedIds.remove(id);
      } else {
        _selectedIds.add(id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final query = _searchController.text.trim();
    final results = query.isEmpty
        ? _friends
        : _friends.where((friend) => friend.name.contains(query)).toList();

    return CommonScaffold(
      title: '친구 추가',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          CommonSearchTextField(
            controller: _searchController,
            hintText: '친구 닉네임을 입력해 주세요.',
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: AppSpacing.x16),
          Wrap(
            spacing: AppSpacing.x8,
            runSpacing: AppSpacing.x8,
            children: [
              for (final friend in _friends.where(
                (friend) => _selectedIds.contains(friend.id),
              ))
                Phase0Chip(label: friend.name, isActive: true),
            ],
          ),
          const SizedBox(height: AppSpacing.x24),
          for (final friend in results) ...[
            Phase0Surface(
              onTap: () => _toggle(friend.id),
              child: Row(
                children: [
                  Phase0UserAvatar(label: friend.name.characters.first),
                  const SizedBox(width: AppSpacing.x12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          friend.name,
                          style: AppTextStyles.size16Bold.copyWith(
                            color: AppColors.textStrong,
                          ),
                        ),
                        Text(
                          friend.email,
                          style: AppTextStyles.size14Medium.copyWith(
                            color: AppColors.textBody,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    _selectedIds.contains(friend.id)
                        ? Icons.check_circle
                        : Icons.radio_button_unchecked,
                    color: _selectedIds.contains(friend.id)
                        ? AppColors.brandStrong
                        : AppColors.textDisabled,
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.x12),
          ],
          const SizedBox(height: AppSpacing.x16),
          CommonButton(
            label: '선택 완료',
            onPressed: _selectedIds.isEmpty
                ? null
                : () => context.go(AppRoutePaths.home),
          ),
        ],
      ),
    );
  }
}

class _FriendCandidate {
  const _FriendCandidate({
    required this.id,
    required this.name,
    required this.email,
  });

  final String id;
  final String name;
  final String email;
}
