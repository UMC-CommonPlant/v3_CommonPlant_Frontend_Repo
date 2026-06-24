import 'package:commonplant_frontend/app/router/app_route_spec.dart';
import 'package:commonplant_frontend/core/theme/app_spacing.dart';
import 'package:commonplant_frontend/shared/widgets/common_scaffold.dart';
import 'package:flutter/material.dart';

class RouteParameterErrorPage extends StatelessWidget {
  const RouteParameterErrorPage({
    super.key,
    required this.route,
    required this.parameterName,
  });

  final AppRouteSpec route;
  final String parameterName;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return CommonScaffold(
      title: route.title,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('라우트 정보를 확인할 수 없어요', style: textTheme.titleLarge),
          const SizedBox(height: AppSpacing.x16),
          Text('필수 경로 값이 누락되었습니다: $parameterName', style: textTheme.bodyMedium),
          const SizedBox(height: AppSpacing.x16),
          Text('routeName: ${route.name}', style: textTheme.bodyMedium),
          const SizedBox(height: AppSpacing.x8),
          Text('path: ${route.path}', style: textTheme.bodyMedium),
        ],
      ),
    );
  }
}
