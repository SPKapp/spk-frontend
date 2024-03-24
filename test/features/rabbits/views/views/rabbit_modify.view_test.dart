import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:spk_app_frontend/features/rabbits/views/widgets/form_fields.dart';
import 'package:spk_app_frontend/features/rabbits/views/views/rabbit_modify.view.dart';

void main() {
  group(RabbitModifyView, () {
    late FieldControlers fieldControlers;

    setUp(() {
      fieldControlers = FieldControlers();
    });

    tearDown(() {
      fieldControlers.dispose();
    });

    testWidgets('RabbitModifyView should render correctly',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RabbitModifyView(
              editControlers: fieldControlers,
            ),
          ),
        ),
      );

      expect(find.byType(SingleChildScrollView), findsOneWidget);
      expect(find.byType(Card), findsOneWidget);
      expect(find.byType(Column), findsOneWidget);
      expect(find.byType(RabbitTextField), findsNWidgets(3));
      expect(find.byKey(const Key('nameTextField')), findsOneWidget);
      expect(find.byKey(const Key('colorTextField')), findsOneWidget);
      expect(find.byKey(const Key('breedTextField')), findsOneWidget);
      expect(find.byType(GenderDropdown), findsOneWidget);
      expect(find.byType(BirthDateField), findsOneWidget);
      expect(find.byType(DateField), findsNWidgets(2));
      expect(find.byKey(const Key('admissionDateField')), findsOneWidget);
      expect(find.byKey(const Key('filingDateField')), findsOneWidget);
      expect(find.byType(AdmissionTypeDropdown), findsOneWidget);
    });

    testWidgets('RabbitTextField should validate input',
        (WidgetTester tester) async {
      final formKey = GlobalKey<FormState>();
      fieldControlers.nameControler.text = '';
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Form(
              key: formKey,
              child: RabbitModifyView(
                editControlers: fieldControlers,
              ),
            ),
          ),
        ),
      );

      formKey.currentState!.validate();
      await tester.pump();

      expect(find.text('Pole nie może być puste'), findsOneWidget);
    });
  });
}
