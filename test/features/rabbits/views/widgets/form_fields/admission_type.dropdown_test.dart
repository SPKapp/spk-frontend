import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:spk_app_frontend/features/rabbits/models/models.dart';
import 'package:spk_app_frontend/features/rabbits/views/widgets/form_fields/admission_type.dropdown.dart';

void main() {
  group(AdmissionTypeDropdown, () {
    testWidgets('AdmissionTypeDropdown should render correctly',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AdmissionTypeDropdown(
              onSelected: (AdmissionType? value) {},
            ),
          ),
        ),
      );

      expect(find.byType(Padding), findsWidgets);
      expect(find.byType(Icon), findsWidgets);
      expect(find.byType(DropdownMenu<AdmissionType>), findsOneWidget);
    });

    testWidgets('AdmissionTypeDropdown should call onSelected',
        (WidgetTester tester) async {
      AdmissionType? selectedValue;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AdmissionTypeDropdown(
              onSelected: (AdmissionType? value) {
                selectedValue = value;
              },
            ),
          ),
        ),
      );

      await tester.tap(find.byType(DropdownMenu<AdmissionType>));
      await tester.pump();

      await tester.tap(find.text('Oddany').last);
      await tester.pump();

      expect(selectedValue, AdmissionType.handedOver);
    });

    testWidgets('AdmissionTypeDropdown should render with initialSelection',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AdmissionTypeDropdown(
              onSelected: (AdmissionType? value) {},
              initialSelection: AdmissionType.returned,
            ),
          ),
        ),
      );

      expect(find.text('Zwrócony'), findsWidgets);
    });
  });
}
