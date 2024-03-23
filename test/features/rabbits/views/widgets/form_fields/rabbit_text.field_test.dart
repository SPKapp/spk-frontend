import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:spk_app_frontend/features/rabbits/views/widgets/form_fields/rabbit_text.field.dart';

void main() {
  group(RabbitTextField, () {
    late TextEditingController controller;

    setUp(() {
      controller = TextEditingController();
    });

    tearDown(() {
      controller.dispose();
    });

    testWidgets('should render correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RabbitTextField(
              controller: controller,
              labelText: 'Label',
              hintText: 'Hint',
              icon: Icons.person,
            ),
          ),
        ),
      );

      expect(find.text('Label'), findsOneWidget);
      expect(find.text('Hint'), findsOneWidget);
      expect(find.byIcon(Icons.person), findsOneWidget);
    });

    testWidgets('should validate input', (WidgetTester tester) async {
      final formKey = GlobalKey<FormState>();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Form(
              key: formKey,
              child: RabbitTextField(
                controller: controller,
                labelText: 'Label',
                hintText: 'Hint',
                icon: Icons.person,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a value';
                  }
                  return null;
                },
              ),
            ),
          ),
        ),
      );

      await tester.enterText(find.byType(TextFormField), '');
      formKey.currentState!.validate();
      await tester.pump();

      expect(find.text('Please enter a value'), findsOneWidget);

      await tester.enterText(find.byType(TextFormField), 'John Doe');
      formKey.currentState!.validate();
      await tester.pump();

      expect(find.text('Please enter a value'), findsNothing);
    });
  });
}
