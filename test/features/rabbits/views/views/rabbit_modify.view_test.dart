import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:spk_app_frontend/features/rabbits/views/widgets/form_fields.dart';
import 'package:spk_app_frontend/features/rabbits/views/views/rabbit_modify.view.dart';

import 'package:spk_app_frontend/features/regions/models/models.dart';

void main() {
  group(RabbitModifyView, () {
    late FieldControlers fieldControlers;

    setUp(() {
      fieldControlers = FieldControlers();
    });

    tearDown(() {
      fieldControlers.dispose();
    });

    testWidgets('should render correctly - privileged',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RabbitModifyView(
              editControlers: fieldControlers,
              privileged: true,
            ),
          ),
        ),
      );

      expect(find.byType(SingleChildScrollView), findsOneWidget);
      expect(find.byType(Card), findsOneWidget);
      expect(find.byType(Column), findsOneWidget);
      expect(find.byType(AppTextField), findsNWidgets(3));
      expect(find.byKey(const Key('nameTextField')), findsOneWidget);
      expect(find.byKey(const Key('colorTextField')), findsOneWidget);
      expect(find.byKey(const Key('breedTextField')), findsOneWidget);
      expect(find.byType(GenderDropdown), findsOneWidget);
      expect(find.byType(BirthDateField), findsOneWidget);
      expect(find.byType(DateField), findsNWidgets(2));
      expect(find.byKey(const Key('admissionDateField')), findsOneWidget);
      expect(find.byKey(const Key('filingDateField')), findsOneWidget);
      expect(find.byType(AdmissionTypeDropdown), findsOneWidget);
      expect(find.byType(RabbitStatusDropdown), findsOneWidget);
      expect(find.byType(DropdownMenu<Region>), findsNothing);
    });

    testWidgets('should render correctly - unprivileged',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RabbitModifyView(
              editControlers: fieldControlers,
              privileged: false,
            ),
          ),
        ),
      );

      expect(find.byType(SingleChildScrollView), findsOneWidget);
      expect(find.byType(Card), findsOneWidget);
      expect(find.byType(Column), findsOneWidget);
      expect(find.byType(AppTextField), findsNWidgets(2));
      expect(find.byKey(const Key('nameTextField')), findsNothing);
      expect(find.byKey(const Key('colorTextField')), findsOneWidget);
      expect(find.byKey(const Key('breedTextField')), findsOneWidget);
      expect(find.byType(GenderDropdown), findsOneWidget);
      expect(find.byType(BirthDateField), findsOneWidget);
      expect(find.byType(DateField), findsNWidgets(1));
      expect(find.byKey(const Key('admissionDateField')), findsOneWidget);
      expect(find.byKey(const Key('filingDateField')), findsNothing);
      expect(find.byType(AdmissionTypeDropdown), findsNothing);
      expect(find.byType(RabbitStatusDropdown), findsOneWidget);
      expect(find.byType(DropdownMenu<Region>), findsNothing);
    });

    testWidgets('should validate input', (WidgetTester tester) async {
      final formKey = GlobalKey<FormState>();
      fieldControlers.nameControler.text = '';
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Form(
              key: formKey,
              child: RabbitModifyView(
                editControlers: fieldControlers,
                privileged: true,
              ),
            ),
          ),
        ),
      );

      formKey.currentState!.validate();
      await tester.pump();

      expect(find.text('Pole nie może być puste'), findsOneWidget);
    });

    testWidgets('should render RegionDropdown', (WidgetTester tester) async {
      const regions = [
        Region(id: 1, name: 'Region 1'),
        Region(id: 2, name: 'Region 2'),
        Region(id: 3, name: 'Region 3'),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RabbitModifyView(
              editControlers: fieldControlers,
              privileged: true,
              regions: regions,
            ),
          ),
        ),
      );

      expect(find.byType(DropdownMenu<Region>), findsOneWidget);
    });
  });
}
