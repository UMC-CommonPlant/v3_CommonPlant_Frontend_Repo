import 'package:commonplant_frontend/app/router/route_paths.dart';
import 'package:commonplant_frontend/core/theme/app_colors.dart';
import 'package:commonplant_frontend/core/theme/app_spacing.dart';
import 'package:commonplant_frontend/core/theme/app_text_styles.dart';
import 'package:commonplant_frontend/features/common/presentation/widgets/phase0_widgets.dart';
import 'package:commonplant_frontend/shared/widgets/common_button.dart';
import 'package:commonplant_frontend/shared/widgets/common_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class TermsPage extends StatefulWidget {
  const TermsPage({super.key});

  @override
  State<TermsPage> createState() => _TermsPageState();
}

class _TermsPageState extends State<TermsPage> {
  bool _isPrivacyAccepted = false;
  bool _isServiceAccepted = false;

  bool get _canContinue => _isPrivacyAccepted && _isServiceAccepted;

  @override
  Widget build(BuildContext context) {
    return CommonScaffold(
      title: '개인정보 이용약관',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            '커먼플랜트 이용을 위해\n필수 약관에 동의해 주세요.',
            style: AppTextStyles.size24Medium.copyWith(
              color: AppColors.textHeadline,
            ),
          ),
          const SizedBox(height: AppSpacing.x24),
          Phase0Surface(
            child: Text(
              '개인정보 수집 및 이용 목적은 회원 식별, 장소와 식물 관리 기능 제공, 서비스 문의 대응입니다. 수집 항목은 닉네임, 프로필 이미지, 서비스 이용 기록이며 회원 탈퇴 시 지체 없이 파기합니다.',
              style: AppTextStyles.size14Medium.copyWith(
                color: AppColors.textStrong,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.x16),
          _TermsCheckTile(
            label: '[필수] 개인정보 수집 및 이용 동의',
            value: _isPrivacyAccepted,
            onChanged: (value) {
              setState(() => _isPrivacyAccepted = value ?? false);
            },
          ),
          _TermsCheckTile(
            label: '[필수] 서비스 이용약관 동의',
            value: _isServiceAccepted,
            onChanged: (value) {
              setState(() => _isServiceAccepted = value ?? false);
            },
          ),
          const SizedBox(height: AppSpacing.x32),
          CommonButton(
            label: '동의하고 시작하기',
            onPressed: _canContinue
                ? () => context.go(AppRoutePaths.home)
                : null,
          ),
        ],
      ),
    );
  }
}

class _TermsCheckTile extends StatelessWidget {
  const _TermsCheckTile({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final bool value;
  final ValueChanged<bool?> onChanged;

  @override
  Widget build(BuildContext context) {
    return CheckboxListTile(
      value: value,
      onChanged: onChanged,
      contentPadding: EdgeInsets.zero,
      controlAffinity: ListTileControlAffinity.leading,
      title: Text(
        label,
        style: AppTextStyles.size16Medium.copyWith(color: AppColors.textStrong),
      ),
    );
  }
}
