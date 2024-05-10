import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:flutter/material.dart';

import 'package:spk_app_frontend/common/views/views.dart';
import 'package:spk_app_frontend/features/rabbit-notes/bloc/rabbit_notes_list.bloc.dart';
import 'package:spk_app_frontend/features/rabbit-notes/models/models.dart';
import 'package:spk_app_frontend/features/rabbits/views/widgets/rabbit_info/weight_history.widget.dart';

class MockRabbitNotesListBloc
    extends MockBloc<RabbitNotesListEvent, RabbitNotesListState>
    implements RabbitNotesListBloc {}

void main() {
  group(WeightHistory, () {
    late RabbitNotesListBloc rabbitNotesListBloc;

    final rabbitNote = RabbitNote(
      id: '1',
      weight: 1.0,
      createdAt: DateTime(2024, 1, 1),
    );

    setUp(() {
      rabbitNotesListBloc = MockRabbitNotesListBloc();
    });

    Widget buildWidget() {
      return MaterialApp(
        home: Scaffold(
          body: WeightHistory(
            rabbitId: '1',
            rabbitNotesListBloc: (_) => rabbitNotesListBloc,
          ),
        ),
      );
    }

    testWidgets('renders InitialView when state is RabbitNotesListInitial',
        (WidgetTester tester) async {
      when(() => rabbitNotesListBloc.state)
          .thenReturn(const RabbitNotesListInitial());

      await tester.pumpWidget(buildWidget());

      expect(find.byType(InitialView), findsOneWidget);
      expect(find.byType(FailureView), findsNothing);
      expect(find.byType(AppListView<RabbitNote>), findsNothing);
    });

    testWidgets('renders FailureView when state is RabbitNotesListFailure',
        (WidgetTester tester) async {
      when(() => rabbitNotesListBloc.state)
          .thenReturn(const RabbitNotesListFailure());

      await tester.pumpWidget(
        buildWidget(),
      );

      expect(find.byType(InitialView), findsNothing);
      expect(find.byType(FailureView), findsOneWidget);
      expect(find.byKey(const Key('appListView')), findsNothing);
    });

    testWidgets('should display "Brak danych." when rabbitNotes is empty',
        (WidgetTester tester) async {
      when(() => rabbitNotesListBloc.state)
          .thenReturn(const RabbitNotesListSuccess(
        rabbitNotes: [],
        hasReachedMax: true,
        totalCount: 0,
      ));

      await tester.pumpWidget(
        buildWidget(),
      );

      expect(find.text('Brak danych'), findsOneWidget);
      expect(find.byKey(const Key('appListView')), findsNothing);
    });

    testWidgets(
        'should display CircularProgressIndicator when hasReachedMax is false',
        (WidgetTester tester) async {
      when(() => rabbitNotesListBloc.state).thenReturn(
        RabbitNotesListSuccess(
          rabbitNotes: [rabbitNote],
          hasReachedMax: false,
          totalCount: 2,
        ),
      );

      await tester.pumpWidget(buildWidget());

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Waga: 1.0 kg'), findsOneWidget);
      expect(find.text('Brak danych.'), findsNothing);
      expect(find.byKey(const Key('appListView')), findsOneWidget);
    });

    testWidgets(
        'should call FetchRabbitNotes event when scroll reaches the end',
        (WidgetTester tester) async {
      when(() => rabbitNotesListBloc.state).thenReturn(
        RabbitNotesListSuccess(
          rabbitNotes: [rabbitNote, rabbitNote],
          hasReachedMax: false,
          totalCount: 4,
        ),
      );

      tester.view.physicalSize = const Size(1000, 500);
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(buildWidget());

      await tester.dragUntilVisible(
        find.byType(CircularProgressIndicator),
        find.byKey(const Key('appListView')),
        const Offset(0, -50),
      );
      verify(() => rabbitNotesListBloc.add(const FetchRabbitNotes())).called(1);
    });
  });
}
