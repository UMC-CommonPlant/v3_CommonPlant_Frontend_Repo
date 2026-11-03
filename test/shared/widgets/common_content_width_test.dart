import 'package:commonplant_frontend/core/theme/app_sizes.dart';
import 'package:commonplant_frontend/shared/widgets/common_content_width.dart';
import 'package:commonplant_frontend/shared/widgets/common_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/test_viewport.dart';

void main() {
  testWidgets('가용폭이 좁으면 채우고 넓으면 입력 폭을 제한한다', (tester) async {
    for (final width in [320.0, 560.0, 884.0]) {
      configureTestViewport(tester, Size(width, 812));
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CommonContentWidth(
              child: SizedBox(key: ValueKey('content'), height: 80),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      final rect = tester.getRect(find.byKey(const ValueKey('content')));
      expect(rect.width, lessThanOrEqualTo(AppSizes.formMaxWidth));
      expect(rect.center.dx, width / 2);
      expect(
        rect.width,
        width < AppSizes.formMaxWidth ? width : AppSizes.formMaxWidth,
      );
      expect(tester.takeException(), isNull);
    }
  });

  testWidgets('일반 scaffold는 읽기 폭을 유지하고 상세는 넓은 배치를 허용한다', (tester) async {
    configureTestViewport(tester, const Size(884, 812));
    for (final maxWidth in [AppSizes.formMaxWidth, AppSizes.contentMaxWidth]) {
      await tester.pumpWidget(
        MaterialApp(
          home: CommonScaffold(
            title: '제목',
            contentMaxWidth: maxWidth,
            bodyPadding: EdgeInsets.zero,
            child: const SizedBox(
              key: ValueKey('content'),
              width: double.infinity,
              height: 100,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      final rect = tester.getRect(find.byKey(const ValueKey('content')));
      expect(rect.width, maxWidth < 884 ? maxWidth : 884);
      expect(rect.center.dx, 442);
      expect(tester.takeException(), isNull);
    }
  });
}
