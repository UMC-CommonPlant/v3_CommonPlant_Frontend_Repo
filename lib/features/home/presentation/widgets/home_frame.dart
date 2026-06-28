import 'package:commonplant_frontend/core/theme/app_colors.dart';
import 'package:commonplant_frontend/features/home/presentation/widgets/home_body.dart';
import 'package:commonplant_frontend/features/home/presentation/widgets/home_hero.dart';
import 'package:flutter/material.dart';

const double _heroContentHeight = 200;

class HomeFrame extends StatelessWidget {
  const HomeFrame({super.key});

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.paddingOf(context).top;
    final heroHeight = topInset + _heroContentHeight;

    return Stack(
      children: [
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(color: AppColors.white),
          ),
        ),
        Positioned(
          left: 0,
          right: 0,
          top: 0,
          height: heroHeight,
          child: HomeHero(
            topInset: topInset,
            contentHeight: _heroContentHeight,
          ),
        ),
        Positioned(
          left: 0,
          right: 0,
          top: heroHeight,
          bottom: 0,
          child: const HomeBody(),
        ),
      ],
    );
  }
}
