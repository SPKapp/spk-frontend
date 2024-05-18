import 'package:flutter_test/flutter_test.dart';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';

import 'package:spk_app_frontend/common/views/widgets/filter_chips.dart';
import 'package:spk_app_frontend/features/rabbit-notes/models/dto.dart';
import 'package:spk_app_frontend/features/rabbit-notes/models/models.dart';
import 'package:spk_app_frontend/features/rabbit-notes/views/widgets/list_page/rabbit_notes_list_filters.widget.dart';

class MockGoRouter extends Mock implements GoRouter {}

void main() {
  group(RabbitNotesListFilters, () {
    late GoRouter goRouter;

    setUp(() {
      goRouter = MockGoRouter();
    });

    Widget buildWidget(RabbitNotesListFilters child) {
      return MaterialApp(
        home: InheritedGoRouter(
          goRouter: goRouter,
          child: Scaffold(
            body: child,
          ),
        ),
      );
    }

    testWidgets('should render correctly - all', (WidgetTester tester) async {
      await tester.pumpWidget(buildWidget(
        RabbitNotesListFilters(
          args: const FindRabbitNotesArgs(rabbitId: '1'),
          onFilter: (args) {},
        ),
      ));

      expect(find.text('Filtruj notatki'), findsOneWidget);
      expect(find.byType(ChoiceChip), findsNWidgets(3));
      expect(find.byType(DateChip), findsNWidgets(2));
      expect(find.byType(FilterChip), findsNothing);
      expect(find.text('Filtruj'), findsOneWidget);
    });

    testWidgets('should render correctly - notes', (WidgetTester tester) async {
      await tester.pumpWidget(buildWidget(
        RabbitNotesListFilters(
          args: const FindRabbitNotesArgs(rabbitId: '1'),
          onFilter: (args) {},
        ),
      ));

      expect(find.text('Filtruj notatki'), findsOneWidget);
      expect(find.byType(ChoiceChip), findsNWidgets(3));
      expect(find.byType(DateChip), findsNWidgets(2));
      expect(find.byType(FilterChip), findsNothing);
      expect(find.text('Filtruj'), findsOneWidget);
    });

    testWidgets('should render correctly - vet visit',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildWidget(
        RabbitNotesListFilters(
          args: const FindRabbitNotesArgs(rabbitId: '1', isVetVisit: true),
          onFilter: (args) {},
        ),
      ));

      expect(find.text('Filtruj notatki'), findsOneWidget);
      expect(find.byType(ChoiceChip), findsNWidgets(3));
      expect(find.byType(DateChip), findsNWidgets(2));
      expect(find.byType(FilterChip), findsNWidgets(VisitType.values.length));
      expect(find.text('Filtruj'), findsOneWidget);
    });

    testWidgets('should update args when choice chips are selected',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        buildWidget(
          RabbitNotesListFilters(
            args: const FindRabbitNotesArgs(rabbitId: '1'),
            onFilter: (args) {},
          ),
        ),
      );

      expect(find.byKey(const Key('visitDate')), findsNothing);
      expect(find.byKey(const Key('noteDate')), findsOneWidget);

      await tester.tap(find.text('Wizyty'));
      await tester.pump();

      expect(find.byKey(const Key('visitDate')), findsOneWidget);
      expect(find.byKey(const Key('noteDate')), findsNothing);

      await tester.tap(find.text('Notatki'));
      await tester.pump();

      expect(find.byKey(const Key('visitDate')), findsNothing);
      expect(find.byKey(const Key('noteDate')), findsOneWidget);
    });

    testWidgets('should update args when filter chips are selected',
        (WidgetTester tester) async {
      bool callbackCalled = false;

      await tester.pumpWidget(
        buildWidget(
          RabbitNotesListFilters(
            args: const FindRabbitNotesArgs(rabbitId: '1', isVetVisit: true),
            onFilter: (args) {
              callbackCalled = true;
            },
          ),
        ),
      );

      await tester.tap(find.byType(FilterChip).first);
      await tester.pump();

      await tester.tap(find.byType(FilterChip).last);
      await tester.pump();

      await tester.tap(find.text('Filtruj'));

      expect(callbackCalled, isTrue);
    });
  });
}
