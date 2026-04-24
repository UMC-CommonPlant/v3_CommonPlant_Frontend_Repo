import 'package:commonplant_frontend/app/router/app_route_spec.dart';
import 'package:commonplant_frontend/core/theme/app_spacing.dart';
import 'package:commonplant_frontend/shared/widgets/common_scaffold.dart';
import 'package:flutter/material.dart';

class RoutePlaceholderPage extends StatelessWidget {
  const RoutePlaceholderPage({
    super.key,
    required this.route,
    required this.pathParameters,
  });

  final AppRouteSpec route;
  final Map<String, String> pathParameters;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return CommonScaffold(
      title: route.title,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('라우트 준비 중', style: textTheme.titleLarge),
          const SizedBox(height: AppSpacing.x16),
          Text('routeName: ${route.name}', style: textTheme.bodyMedium),
          const SizedBox(height: AppSpacing.x8),
          Text('path: ${route.path}', style: textTheme.bodyMedium),
          if (pathParameters.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.x16),
            Text('Path parameters', style: textTheme.titleMedium),
            const SizedBox(height: AppSpacing.x8),
            for (final entry in pathParameters.entries)
              Text('${entry.key}: ${entry.value}', style: textTheme.bodyMedium),
          ],
          const SizedBox(height: AppSpacing.x16),
          Text('Figma frames', style: textTheme.titleMedium),
          const SizedBox(height: AppSpacing.x8),
          for (final frameName in route.figmaFrames)
            Text(frameName, style: textTheme.bodyMedium),
        ],
      ),
    );
  }
}
