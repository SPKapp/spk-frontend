import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:spk_app_frontend/features/rabbits/models/models.dart';
import 'package:spk_app_frontend/features/rabbits/views/widgets/form_fields/rabbit_status.dropdown.dart';

void main() {
  group(RabbitStatusDropdown, () {
    testWidgets('should render correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RabbitStatusDropdown(
              onSelected: (value) {},
            ),
          ),
        ),
      );

      expect(find.byType(Padding), findsWidgets);
      expect(find.byType(Icon), findsWidgets);
      expect(find.byType(DropdownMenu<RabbitStatus>), findsOneWidget);
    });

    testWidgets('should call onSelected', (WidgetTester tester) async {
      RabbitStatus? selectedValue;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RabbitStatusDropdown(
              onSelected: (value) {
                selectedValue = value;
              },
            ),
          ),
        ),
      );

      await tester.tap(find.byType(DropdownMenu<RabbitStatus>));
      await tester.pump();

      await tester.tap(find.text(RabbitStatus.adoptable.displayName).last);
      await tester.pump();

      expect(selectedValue, RabbitStatus.adoptable);
    });

    testWidgets('should render with initialSelection',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RabbitStatusDropdown(
              onSelected: (value) {},
              initialSelection: RabbitStatus.adoptable,
            ),
          ),
        ),
      );

      expect(find.text(RabbitStatus.adoptable.displayName), findsWidgets);
    });
  });
}
