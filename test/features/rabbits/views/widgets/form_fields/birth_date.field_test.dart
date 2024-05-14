import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spk_app_frontend/common/extensions/date_time.extension.dart';

import 'package:spk_app_frontend/features/rabbits/views/widgets/form_fields/birth_date.field.dart';

void main() {
  group(BirthDateField, () {
    late TextEditingController controller;
    late bool confirmedBirthDate;
    late DateTime selectedDate;

    setUp(() {
      controller = TextEditingController();
      confirmedBirthDate = false;
      selectedDate = DateTime(2024, 1, 1);
      controller.text = selectedDate.toDateString();
    });

    Widget buildWidget() {
      return MaterialApp(
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
    }

    tearDown(() {
      controller.dispose();
    });

    testWidgets('renders BirthDateField correctly',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildWidget());

      expect(find.byType(Padding), findsWidgets);
      expect(find.byType(Icon), findsWidgets);
      expect(find.byType(TextFormField), findsOneWidget);
      expect(find.text('Data urodzenia'), findsOneWidget);
      expect(find.text('Podaj datę urodzenia królika'), findsOneWidget);
      expect(find.text('Przybliżona data'), findsOneWidget);
    });

    testWidgets('test date confirmation', (WidgetTester tester) async {
      await tester.pumpWidget(buildWidget());

      expect(find.text('Przybliżona data'), findsOneWidget);

      await tester.tap(find.byKey(const Key('confirmBirthDateButton')));
      await tester.pumpAndSettle();

      expect(confirmedBirthDate, true);
      expect(find.text('Dokładna data'), findsOneWidget);
    });

    testWidgets('test date selection', (WidgetTester tester) async {
      await tester.pumpWidget(buildWidget());

      await tester.tap(find.byType(TextFormField));
      await tester.pumpAndSettle();

      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();

      expect(selectedDate, DateUtils.dateOnly(DateTime.now()));
    });
  });
}
