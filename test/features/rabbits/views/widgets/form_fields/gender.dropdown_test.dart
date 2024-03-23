import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:spk_app_frontend/features/rabbits/models/models.dart';
import 'package:spk_app_frontend/features/rabbits/views/widgets/form_fields/gender.dropdown.dart';

void main() {
  group(GenderDropdown, () {
    testWidgets('GenderDropdown should render correctly',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GenderDropdown(
              onSelected: (gender) {},
              initialSelection: Gender.unknown,
            ),
          ),
        ),
      );

      expect(find.byType(Padding), findsWidgets);
      expect(find.byType(Icon), findsWidgets);
      expect(find.byType(DropdownMenu<Gender>), findsOneWidget);
    });

    testWidgets('GenderDropdown should call onSelected',
        (WidgetTester tester) async {
      Gender? selectedValue;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GenderDropdown(
              onSelected: (Gender? value) {
                selectedValue = value;
              },
            ),
          ),
        ),
      );

      await tester.tap(find.byType(DropdownMenu<Gender>));
      await tester.pump();

      await tester.tap(find.text('Samiec').last);
      await tester.pump();

      expect(selectedValue, Gender.male);
    });

    testWidgets('GenderDropdown should render with initialSelection',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GenderDropdown(
              onSelected: (Gender? value) {},
              initialSelection: Gender.female,
            ),
          ),
        ),
      );

      expect(find.text('Samiczka'), findsWidgets);
    });
  });
}
