import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:spk_app_frontend/features/rabbits/views/widgets/rabbit_info/rabbit_info_button.widget.dart';

void main() {
  group(RabbitInfoButton, () {
    testWidgets('should call onPressed when pressed',
        (WidgetTester tester) async {
      bool onPressedCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RabbitInfoButton(
              onPressed: () {
                onPressedCalled = true;
              },
              text: 'Test Button',
            ),
          ),
        ),
      );

      final buttonFinder = find.byType(ElevatedButton);
      expect(buttonFinder, findsOneWidget);

      await tester.tap(buttonFinder);
      await tester.pump();

      expect(onPressedCalled, true);
    });

    testWidgets('should display text', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RabbitInfoButton(
              onPressed: () {},
              text: 'Test Button',
              right: false,
            ),
          ),
        ),
      );

      final textFinder = find.text('Test Button');
      expect(textFinder, findsOneWidget);
    });
  });
}
