import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:spk_app_frontend/features/rabbit-notes/bloc/rabbit_notes_list.bloc.dart';
import 'package:spk_app_frontend/features/rabbit-notes/models/models.dart';
import 'package:spk_app_frontend/features/rabbit-notes/views/views/rabbit_notes_list.view.dart';

class MockRabbitNotesListBloc
    extends MockBloc<RabbitNotesListEvent, RabbitNotesListState>
    implements RabbitNotesListBloc {}

void main() {
  group(RabbitNotesListView, () {
    late RabbitNotesListBloc rabbitNotesListBloc;

    final rabbitNotes = [
      RabbitNote(
        id: 1,
        description: 'Notatka 1',
        createdAt: DateTime(2024, 1, 1),
      ),
      RabbitNote(
        id: 2,
        description: 'Notatka 2',
        createdAt: DateTime(2024, 1, 2),
      ),
    ];

    setUp(() {
      rabbitNotesListBloc = MockRabbitNotesListBloc();
    });

    Widget buildWidget(Widget child) {
      return MaterialApp(
        home: Scaffold(
          body: BlocProvider.value(
            value: rabbitNotesListBloc,
            child: child,
          ),
        ),
      );
    }

    testWidgets('should display "Brak notatek." when rabbitNotes is empty',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        buildWidget(
          const RabbitNotesListView(
            rabbitNotes: [],
            hasReachedMax: true,
          ),
        ),
      );

      expect(find.text('Brak notatek.'), findsOneWidget);
      expect(find.byKey(const Key('appListView')), findsNothing);
    });

    testWidgets(
        'should display CircularProgressIndicator when hasReachedMax is false',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        buildWidget(
          RabbitNotesListView(
            rabbitNotes: rabbitNotes,
            hasReachedMax: false,
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Brak notatek.'), findsNothing);
      expect(find.byKey(const Key('appListView')), findsOneWidget);
    });

    testWidgets('should display rabbit notes when rabbitNotes is not empty',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        buildWidget(
          RabbitNotesListView(
            rabbitNotes: rabbitNotes,
            hasReachedMax: true,
          ),
        ),
      );

      expect(find.text('Notatka 1'), findsOneWidget);
      expect(find.text('Notatka 2'), findsOneWidget);
    });

    testWidgets(
        'should call FetchRabbitNotes event when scroll reaches the end',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1000, 500);
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        buildWidget(
          RabbitNotesListView(
            rabbitNotes: rabbitNotes,
            hasReachedMax: false,
          ),
        ),
      );

      await tester.dragUntilVisible(
        find.byType(CircularProgressIndicator),
        find.byKey(const Key('appListView')),
        const Offset(0, -200),
      );

      verify(() => rabbitNotesListBloc.add(const FetchRabbitNotes())).called(1);
    });

    testWidgets(
        'should call RefreshRabbitNotes event when pull-to-refresh is triggered',
        (WidgetTester tester) async {
      whenListen(
        rabbitNotesListBloc,
        Stream.fromIterable([
          const RabbitNotesListInitial(),
          const RabbitNotesListSuccess(
            rabbitNotes: [],
            hasReachedMax: true,
            totalCount: 0,
          ),
        ]),
      );

      await tester.pumpWidget(
        buildWidget(
          RabbitNotesListView(
            rabbitNotes: rabbitNotes,
            hasReachedMax: true,
          ),
        ),
      );

      await tester.fling(
        find.byKey(const Key('appListView')),
        const Offset(0, 400),
        1000,
      );
      await tester.pumpAndSettle();

      verify(() => rabbitNotesListBloc.add(
            const RefreshRabbitNotes(null),
          )).called(1);
    });
  });
}
