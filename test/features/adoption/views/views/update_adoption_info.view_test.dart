import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spk_app_frontend/common/views/widgets/form_fields.dart';
import 'package:spk_app_frontend/features/adoption/views/views/update_adoption_info.view.dart';

void main() {
  group(UpdateAdoptionInfoView, () {
    late FieldControlers fieldControlers;

    setUp(() {
      fieldControlers = FieldControlers();
    });

    tearDown(() {
      fieldControlers.dispose();
    });

    testWidgets('renders description field', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: UpdateAdoptionInfoView(
            editControlers: fieldControlers,
          ),
        ),
      );

      expect(find.byKey(const Key('descriptionField')), findsOneWidget);
    });

    testWidgets('updates description field text', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: UpdateAdoptionInfoView(
            editControlers: fieldControlers,
          ),
        ),
      );

      final descriptionField = find.byKey(const Key('descriptionField'));
      expect(descriptionField, findsOneWidget);

      await tester.enterText(descriptionField, 'New description');
      expect(fieldControlers.descriptionControler.text, 'New description');
    });

    testWidgets('renders date field', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: UpdateAdoptionInfoView(
            editControlers: fieldControlers,
          ),
        ),
      );

      expect(find.byType(DateField), findsOneWidget);
    });

    testWidgets('updates date field text', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: UpdateAdoptionInfoView(
            editControlers: fieldControlers,
          ),
        ),
      );

      final dateField = find.byType(DateField);
      expect(dateField, findsOneWidget);

      await tester.tap(dateField);
      await tester.pumpAndSettle();

      // Simulate selecting a date
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();

      expect(fieldControlers.dateControler.text.isNotEmpty, true);
    });
  });
}
