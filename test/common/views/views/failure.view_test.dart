import 'package:flutter_test/flutter_test.dart';

import 'package:flutter/material.dart';

import 'package:spk_app_frontend/common/views/views/failure.view.dart';

void main() {
  group(FailureView, () {
    testWidgets('FailureView displays correct message',
        (WidgetTester tester) async {
      const String errorMessage = 'Something went wrong';
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FailureView(
              message: errorMessage,
              onPressed: () {},
            ),
          ),
        ),
      );

      final textFinder = find.text(errorMessage);
      expect(textFinder, findsOneWidget);
    });

    testWidgets('FailureView calls onPressed when button is pressed',
        (WidgetTester tester) async {
      bool onPressedCalled = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FailureView(
              message: 'Error',
              onPressed: () {
                onPressedCalled = true;
              },
            ),
          ),
        ),
      );

      final buttonFinder = find.byType(FilledButton);
      expect(buttonFinder, findsOneWidget);

      await tester.tap(buttonFinder);
      expect(onPressedCalled, true);
    });

    testWidgets('FailureView does not display button when onPressed is null',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: FailureView(
              message: 'Error',
            ),
          ),
        ),
      );

      final buttonFinder = find.byType(FilledButton);
      expect(buttonFinder, findsNothing);
    });
  });
}
