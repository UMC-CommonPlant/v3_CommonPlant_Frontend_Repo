import 'package:commonplant_frontend/core/theme/app_colors.dart';
import 'package:flutter/widgets.dart';

/// 실제로 화면을 분리하는 접힘·힌지를 피해 앱과 overlay를 같은 영역에 둔다.
class CommonDisplayArea extends StatelessWidget {
  const CommonDisplayArea({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.canvas,
      child: DisplayFeatureSubScreen(child: child),
    );
  }
}
