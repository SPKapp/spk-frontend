import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';

import 'package:spk_app_frontend/common/views/widgets/filter_chips.dart';
import 'package:spk_app_frontend/features/rabbit-notes/bloc/rabbit_notes_list.bloc.dart';
import 'package:spk_app_frontend/features/rabbit-notes/models/dto.dart';
import 'package:spk_app_frontend/features/rabbit-notes/models/models.dart';
import 'package:spk_app_frontend/features/rabbit-notes/views/widgets/list_page/rabbit_notes_list_filters.widget.dart';

class MockRabbitNotesListBloc
    extends MockBloc<RabbitNotesListEvent, RabbitNotesListState>
    implements RabbitNotesListBloc {}

class MockGoRouter extends Mock implements GoRouter {}

void main() {
  group(RabbitNotesListFilters, () {
    late RabbitNotesListBloc rabbitNotesListBloc;
    late GoRouter goRouter;

    setUp(() {
      rabbitNotesListBloc = MockRabbitNotesListBloc();
      goRouter = MockGoRouter();
    });

    Widget buildWidget(FindRabbitNotesArgs args) {
      return MaterialApp(
        home: InheritedGoRouter(
          goRouter: goRouter,
          child: BlocProvider(
            create: (context) => rabbitNotesListBloc,
            child: Scaffold(
              body: RabbitNotesListFilters(
                args: args,
              ),
            ),
          ),
        ),
      );
    }

    testWidgets('should render correctly - all', (WidgetTester tester) async {
      await tester.pumpWidget(
        buildWidget(const FindRabbitNotesArgs(rabbitId: 1)),
      );

      expect(find.text('Filtruj notatki'), findsOneWidget);
      expect(find.byType(ChoiceChip), findsNWidgets(3));
      expect(find.byType(DateChip), findsNWidgets(2));
      expect(find.byType(FilterChip), findsNothing);
      expect(find.text('Filtruj'), findsOneWidget);
    });

    testWidgets('should render correctly - notes', (WidgetTester tester) async {
      await tester.pumpWidget(
        buildWidget(const FindRabbitNotesArgs(rabbitId: 1)),
      );

      expect(find.text('Filtruj notatki'), findsOneWidget);
      expect(find.byType(ChoiceChip), findsNWidgets(3));
      expect(find.byType(DateChip), findsNWidgets(2));
      expect(find.byType(FilterChip), findsNothing);
      expect(find.text('Filtruj'), findsOneWidget);
    });

    testWidgets('should render correctly - vet visit',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        buildWidget(const FindRabbitNotesArgs(rabbitId: 1, isVetVisit: true)),
      );

      expect(find.text('Filtruj notatki'), findsOneWidget);
      expect(find.byType(ChoiceChip), findsNWidgets(3));
      expect(find.byType(DateChip), findsNWidgets(2));
      expect(find.byType(FilterChip), findsNWidgets(VisitType.values.length));
      expect(find.text('Filtruj'), findsOneWidget);
    });

    testWidgets('should update args when choice chips are selected',
        (WidgetTester tester) async {
      FindRabbitNotesArgs args = const FindRabbitNotesArgs(rabbitId: 1);

      await tester.pumpWidget(
        buildWidget(args),
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
      await tester.pumpWidget(
        buildWidget(const FindRabbitNotesArgs(rabbitId: 1, isVetVisit: true)),
      );

      await tester.tap(find.byType(FilterChip).first);
      await tester.pump();

      await tester.tap(find.byType(FilterChip).last);
      await tester.pump();

      await tester.tap(find.text('Filtruj'));

      verify(
        () => rabbitNotesListBloc.add(
          RefreshRabbitNotes(
            FindRabbitNotesArgs(
              rabbitId: 1,
              isVetVisit: true,
              vetVisit: VetVisitArgs(
                visitTypes: [VisitType.values.first, VisitType.values.last],
              ),
            ),
          ),
        ),
      ).called(1);
    });
  });
}
