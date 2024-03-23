import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:spk_app_frontend/features/rabbits/views/widgets/form_fields/birth_date.field.dart';

void main() {
  group(BirthDateField, () {
    late TextEditingController controller;
    late bool confirmedBirthDate;
    late DateTime selectedDate;

    late Widget widget;

    setUp(() {
      controller = TextEditingController();
      confirmedBirthDate = false;
      selectedDate = DateTime(2024, 1, 1);

      widget = MaterialApp(
        home: Scaffold(
          body: BirthDateField(
            controller: controller,
            onTap: (date) {
              selectedDate = date;
            },
            onConfirmedBirthDate: () {
              confirmedBirthDate = !confirmedBirthDate;
            },
            confirmedBirthDate: confirmedBirthDate,
          ),
        ),
      );
    });

    tearDown(() {
      controller.dispose();
    });

    testWidgets('renders BirthDateField correctly',
        (WidgetTester tester) async {
      await tester.pumpWidget(widget);

      expect(find.byType(Padding), findsWidgets);
      expect(find.byType(Icon), findsWidgets);
      expect(find.byType(TextFormField), findsOneWidget);
      expect(find.text('Data urodzenia'), findsOneWidget);
      expect(find.text('Podaj datę urodzenia królika'), findsOneWidget);
      expect(find.text('Przybliżona data'), findsOneWidget);
    });

    testWidgets('test date confirmation', (WidgetTester tester) async {
      await tester.pumpWidget(widget);

      expect(find.text('Przybliżona data'), findsOneWidget);

      await tester.tap(find.byType(TextButton));
      await tester.pumpAndSettle();

      expect(confirmedBirthDate, true);
      expect(find.text('Dokładna data'), findsOneWidget);
    });

    testWidgets('test date selection', (WidgetTester tester) async {
      await tester.pumpWidget(widget);

      await tester.tap(find.byType(TextFormField));
      await tester.pumpAndSettle();

      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();

      expect(selectedDate, DateUtils.dateOnly(DateTime.now()));
    });
  });
}
