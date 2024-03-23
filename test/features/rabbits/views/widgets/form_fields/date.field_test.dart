import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:spk_app_frontend/features/rabbits/views/widgets/form_fields/date.field.dart';

void main() {
  group(DateField, () {
    late TextEditingController controller;
    late String labelText;
    late String hintText;
    late IconData icon;
    late void Function(DateTime) onTap;
    late int daysBefore;
    late int daysAfter;

    setUp(() {
      controller = TextEditingController();
      labelText = 'Date';
      hintText = 'Select a date';
      icon = Icons.calendar_today;
      onTap = (date) {};
      daysBefore = 3650;
      daysAfter = 365;
    });

    tearDown(() {
      controller.dispose();
    });

    testWidgets('renders correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DateField(
              controller: controller,
              labelText: labelText,
              hintText: hintText,
              icon: icon,
              onTap: onTap,
              daysBefore: daysBefore,
              daysAfter: daysAfter,
            ),
          ),
        ),
      );

      expect(find.byType(TextFormField), findsOneWidget);
      expect(find.text(labelText), findsOneWidget);
      expect(find.text(hintText), findsOneWidget);
      expect(find.byIcon(icon), findsOneWidget);
    });

    testWidgets('calls onTap when date is selected',
        (WidgetTester tester) async {
      DateTime selectedDate = DateUtils.dateOnly(
        DateTime.now().subtract(
          const Duration(days: 3),
        ),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DateField(
              controller: controller,
              labelText: labelText,
              hintText: hintText,
              icon: icon,
              onTap: (date) {
                selectedDate = date;
              },
            ),
          ),
        ),
      );

      await tester.tap(find.byType(TextFormField));
      await tester.pumpAndSettle();

      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();

      expect(selectedDate, DateUtils.dateOnly(DateTime.now()));
    });
  });
}
