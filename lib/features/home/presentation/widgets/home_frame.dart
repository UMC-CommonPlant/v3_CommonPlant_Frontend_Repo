import 'package:commonplant_frontend/core/theme/app_colors.dart';
import 'package:commonplant_frontend/core/theme/app_sizes.dart';
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

    return ColoredBox(
      color: AppColors.white,
      child: LayoutBuilder(
        builder: (context, constraints) => HomeBody(
          header: HomeHero(
            topInset: topInset,
            contentHeight: _heroContentHeight,
          ),
          headerHeight: heroHeight,
          headerMinHeight: topInset,
          collapseHeader:
              constraints.maxHeight <= AppSizes.compactLayoutMaxHeight,
        ),
      ),
    );
  }
}
