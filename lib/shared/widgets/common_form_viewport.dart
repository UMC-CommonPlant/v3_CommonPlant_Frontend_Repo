import 'dart:math' as math;

import 'package:commonplant_frontend/core/theme/app_sizes.dart';
import 'package:commonplant_frontend/core/theme/app_spacing.dart';
import 'package:flutter/widgets.dart';

/// 평소 폼의 고정 하단 액션을 유지하고, 키보드로 가용 높이가 작아지면
/// 내비게이션·입력 영역·액션 전체를 스크롤할 수 있게 한다.
class CommonFormViewport extends StatelessWidget {
  const CommonFormViewport({
    super.key,
    required this.child,
    this.minHeight =
        AppSizes.navigationBarHeight +
        AppSizes.addressOrPlaceFieldHeight +
        AppSizes.buttonHeight +
        AppSpacing.x16,
  });

  final Widget child;

  /// 내비게이션, 최소 한 입력줄, 액션과 하단 여백이 함께 놓일 높이.
  /// 액션에 추가 여백이 있는 폼만 해당 토큰 합으로 조정한다.
  final double minHeight;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          primary: false,
          child: SizedBox(
            height: math.max(constraints.maxHeight, minHeight),
            child: child,
          ),
        );
      },
    );
  }
}
