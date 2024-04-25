import 'package:flutter_test/flutter_test.dart';

import 'package:flutter/material.dart';

import 'package:spk_app_frontend/features/rabbit-notes/models/enums/visit-type.enum.dart';
import 'package:spk_app_frontend/features/rabbit-notes/views/views/rabbit_note_modify.view.dart';

void main() {
  group(RabbitNoteModifyView, () {
    late FieldControlers editControlers;
    late GlobalKey<FormState> formKey;

    setUp(() {
      editControlers = FieldControlers();
      formKey = GlobalKey<FormState>();
    });

    tearDown(() {
      editControlers.dispose();
    });

    Widget buildWidget(Widget child) {
      return MaterialApp(
        home: Scaffold(
          body: Form(
            key: formKey,
            child: child,
          ),
        ),
      );
    }

    testWidgets('should display ChoiceChips when canChangeType is true',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildWidget(
        RabbitNoteModifyView(
          editControlers: editControlers,
          canChangeType: true,
        ),
      ));

      expect(find.byType(ChoiceChip), findsNWidgets(2));
    });

    testWidgets('should not display ChoiceChips when canChangeType is false',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildWidget(
        RabbitNoteModifyView(
          editControlers: editControlers,
          canChangeType: false,
        ),
      ));

      expect(find.byType(ChoiceChip), findsNothing);
    });

    testWidgets('should display noteCard when isVetVisit is false',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildWidget(
        RabbitNoteModifyView(
          editControlers: editControlers,
          canChangeType: false,
        ),
      ));

      expect(find.byKey(const Key('noteCard')), findsOneWidget);
      expect(find.byKey(const Key('vetVisitCard')), findsNothing);
    });

    testWidgets('should display vetVisitCard when isVetVisit is true',
        (WidgetTester tester) async {
      editControlers.isVetVisit = true;

      await tester.pumpWidget(buildWidget(
        RabbitNoteModifyView(
          editControlers: editControlers,
          canChangeType: false,
        ),
      ));

      expect(find.byKey(const Key('noteCard')), findsNothing);
      expect(find.byKey(const Key('vetVisitCard')), findsOneWidget);
    });

    testWidgets('should display vaccinationInput, operationInput and chipInput',
        (WidgetTester tester) async {
      editControlers.isVetVisit = true;

      await tester.pumpWidget(buildWidget(
        RabbitNoteModifyView(
          editControlers: editControlers,
          canChangeType: false,
        ),
      ));

      await tester
          .tap(find.byKey(Key('${VisitType.vaccination.toString()}Chip')));
      await tester
          .tap(find.byKey(Key('${VisitType.operation.toString()}Chip')));
      await tester.tap(find.byKey(Key('${VisitType.chip.toString()}Chip')));
      await tester.pump();

      expect(find.byKey(const Key('vaccinationInput')), findsOneWidget);
      expect(find.byKey(const Key('operationInput')), findsOneWidget);
      expect(find.byKey(const Key('chipInput')), findsOneWidget);
    });

    testWidgets(
        'should disable VisitType.control when VisitType.treatment is selected',
        (WidgetTester tester) async {
      editControlers.isVetVisit = true;

      await tester.pumpWidget(buildWidget(
        RabbitNoteModifyView(
          editControlers: editControlers,
          canChangeType: false,
        ),
      ));

      await tester.tap(find.byKey(Key('${VisitType.control.toString()}Chip')));
      await tester
          .tap(find.byKey(Key('${VisitType.treatment.toString()}Chip')));
      await tester.pump();

      expect(editControlers.types.contains(VisitType.control), false);
      expect(editControlers.types.contains(VisitType.treatment), true);

      await tester.tap(find.byKey(Key('${VisitType.control.toString()}Chip')));
      await tester.pump();

      expect(editControlers.types.contains(VisitType.control), true);
      expect(editControlers.types.contains(VisitType.treatment), false);
    });

    testWidgets('should display error message when form is invalid',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildWidget(
        RabbitNoteModifyView(
          editControlers: editControlers,
          canChangeType: false,
        ),
      ));

      formKey.currentState!.validate();
      await tester.pump();

      expect(find.text('Pole nie może być puste'), findsOneWidget);
    });
  });
}
