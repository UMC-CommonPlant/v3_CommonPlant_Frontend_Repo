import 'package:flutter/widgets.dart';

abstract final class AppMotion {
  const AppMotion._();

  static const Duration fast = Duration(milliseconds: 180);
  static const Curve standardCurve = Curves.easeOutCubic;

  static Duration durationOf(BuildContext context, Duration duration) {
    return MediaQuery.disableAnimationsOf(context) ? Duration.zero : duration;
  }
}
