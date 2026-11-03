import 'package:commonplant_frontend/core/theme/app_sizes.dart';
import 'package:flutter/widgets.dart';

/// 가용 폭은 따르되 읽기·입력 영역이 과도하게 늘어나지 않게 한다.
class CommonContentWidth extends StatelessWidget {
  const CommonContentWidth({
    super.key,
    required this.child,
    this.maxWidth = AppSizes.formMaxWidth,
  });

  final Widget child;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      heightFactor: 1,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: SizedBox(width: double.infinity, child: child),
      ),
    );
  }
}
