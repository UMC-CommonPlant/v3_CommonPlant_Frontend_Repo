import 'package:commonplant_frontend/app/router/route_paths.dart';
import 'package:commonplant_frontend/core/theme/app_colors.dart';
import 'package:commonplant_frontend/features/home/presentation/widgets/home_bottom_tab_bar.dart';
import 'package:commonplant_frontend/features/home/presentation/widgets/home_frame.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: AppColors.surfaceAlt,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: AppColors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: AppColors.white,
        bottomNavigationBar: HomeBottomTabBar(
          onMyPressed: () => context.go(AppRoutePaths.userProfile),
        ),
        body: const HomeFrame(),
      ),
    );
  }
}
