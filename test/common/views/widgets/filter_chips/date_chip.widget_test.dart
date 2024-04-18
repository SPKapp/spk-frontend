import 'package:flutter_test/flutter_test.dart';

import 'package:flutter/material.dart';

import 'package:spk_app_frontend/common/views/widgets/filter_chips/date_chip.widget.dart';

void main() {
  group('DateChip', () {
    testWidgets('should display empty text when date is null',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DateChip(
              date: null,
              filledText: 'Filled Text',
              onDateChanged: (date) {},
            ),
          ),
        ),
      );

      expect(find.text('Wybierz datę'), findsOneWidget);
      expect(find.text('Filled Text'), findsNothing);
    });

    testWidgets('should display filled text when date is not null',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DateChip(
              date: DateTime.now(),
              onDateChanged: (date) {},
              filledText: 'Filled Text',
            ),
          ),
        ),
      );

      expect(find.text('Wybierz datę'), findsNothing);
      expect(find.text('Filled Text'), findsOneWidget);
    });

    testWidgets('should call onDateChanged when chip is selected',
        (WidgetTester tester) async {
      DateTime? selectedDate;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DateChip(
              date: null,
              onDateChanged: (date) {
                selectedDate = date;
              },
            ),
          ),
        ),
      );

      await tester.tap(find.byType(InputChip));
      await tester.pumpAndSettle();

      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();

      expect(selectedDate, isNotNull);
    });

    testWidgets('should call onDateChanged with null when chip is deleted',
        (WidgetTester tester) async {
      DateTime? selectedDate = DateTime.now();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DateChip(
              date: selectedDate,
              onDateChanged: (date) {
                selectedDate = date;
              },
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      await tester.tap(
        find.descendant(
          of: find.byType(InputChip),
          matching: find.byIcon(Icons.clear),
        ),
      );
      await tester.pumpAndSettle();

      expect(selectedDate, isNull);
    });
  });
}
