import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:spk_app_frontend/common/views/widgets/lists/card.widget.dart';

void main() {
  group(AppCard, () {
    testWidgets('AppCard should render child widget',
        (WidgetTester tester) async {
      final childWidget = Container();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppCard(
              child: childWidget,
            ),
          ),
        ),
      );

      final childFinder = find.byWidget(childWidget);
      expect(childFinder, findsOneWidget);
    });
  });
}
