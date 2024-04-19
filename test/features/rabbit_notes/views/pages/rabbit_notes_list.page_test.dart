import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:flutter/material.dart';

import 'package:spk_app_frontend/common/views/views.dart';
import 'package:spk_app_frontend/features/rabbit-notes/bloc/rabbit_notes_list.bloc.dart';
import 'package:spk_app_frontend/features/rabbit-notes/models/dto.dart';
import 'package:spk_app_frontend/features/rabbit-notes/models/models.dart';
import 'package:spk_app_frontend/features/rabbit-notes/views/pages/rabbit_notes_list.page.dart';
import 'package:spk_app_frontend/features/rabbit-notes/views/views/rabbit_notes_list.view.dart';

class MockRabbitNotesListBloc
    extends MockBloc<RabbitNotesListEvent, RabbitNotesListState>
    implements RabbitNotesListBloc {}

void main() {
  group(RabbitNotesListPage, () {
    late RabbitNotesListBloc rabbitNotesListBloc;

    setUp(() {
      rabbitNotesListBloc = MockRabbitNotesListBloc();
    });

    Widget buildWidget({String? name, bool? isVetVisit}) {
      return MaterialApp(
        home: RabbitNotesListPage(
          rabbitId: 1,
          rabbitName: name,
          isVetVisit: isVetVisit,
          rabbitNotesListBloc: (context) => rabbitNotesListBloc,
        ),
      );
    }

    testWidgets(
        'should render initial view when state is RabbitNotesListInitial',
        (WidgetTester tester) async {
      when(() => rabbitNotesListBloc.state)
          .thenReturn(const RabbitNotesListInitial());

      await tester.pumpWidget(
        buildWidget(name: 'Test Rabbit'),
      );

      expect(find.text('Test Rabbit'), findsOneWidget);
      expect(find.byType(InitialView), findsOneWidget);
      expect(find.byType(FailureView), findsNothing);
      expect(find.byType(RabbitNotesListView), findsNothing);
      expect(find.byKey(const Key('errorSnackBar')), findsNothing);
    });

    testWidgets('should render initial view without rabbit name',
        (WidgetTester tester) async {
      when(() => rabbitNotesListBloc.state)
          .thenReturn(const RabbitNotesListInitial());

      await tester.pumpWidget(
        buildWidget(name: null),
      );

      expect(find.text('Historia Notatek'), findsOneWidget);
      expect(find.byType(InitialView), findsOneWidget);
      expect(find.byType(FailureView), findsNothing);
      expect(find.byType(RabbitNotesListView), findsNothing);
      expect(find.byKey(const Key('errorSnackBar')), findsNothing);
    });

    testWidgets(
        'should render failure view when state is RabbitNotesListFailure and rabbit notes are empty',
        (WidgetTester tester) async {
      when(() => rabbitNotesListBloc.state)
          .thenReturn(const RabbitNotesListFailure());

      await tester.pumpWidget(
        buildWidget(name: 'Test Rabbit'),
      );

      expect(find.text('Test Rabbit'), findsOneWidget);
      expect(find.byType(InitialView), findsNothing);
      expect(find.byType(FailureView), findsOneWidget);
      expect(find.byType(RabbitNotesListView), findsNothing);
      expect(find.byKey(const Key('errorSnackBar')), findsNothing);
    });

    testWidgets(
        'should render failure view when state is RabbitNotesListFailure and rabbit notes are not empty',
        (WidgetTester tester) async {
      whenListen(
          rabbitNotesListBloc,
          Stream.fromIterable([
            const RabbitNotesListFailure(
              rabbitNotes: [
                RabbitNote(
                  id: 1,
                  description: 'Test note',
                ),
              ],
              hasReachedMax: true,
              totalCount: 1,
            ),
          ]),
          initialState: const RabbitNotesListSuccess(
            rabbitNotes: [
              RabbitNote(
                id: 1,
                description: 'Test note',
              ),
            ],
            hasReachedMax: true,
            totalCount: 1,
          ));

      await tester.pumpWidget(
        buildWidget(name: 'Test Rabbit'),
      );

      await tester.pump();

      expect(find.text('Test Rabbit'), findsOneWidget);
      expect(find.byType(InitialView), findsNothing);
      expect(find.byType(FailureView), findsNothing);
      expect(find.byType(RabbitNotesListView), findsOneWidget);
      expect(find.byKey(const Key('errorSnackBar')), findsOneWidget);
    });

    testWidgets(
        'should render rabbit notes list view when state is RabbitNotesListSuccess',
        (WidgetTester tester) async {
      when(() => rabbitNotesListBloc.state).thenReturn(
        const RabbitNotesListSuccess(
          rabbitNotes: [
            RabbitNote(
              id: 1,
              description: 'Test note',
            ),
          ],
          hasReachedMax: true,
          totalCount: 1,
        ),
      );

      await tester.pumpWidget(
        buildWidget(name: 'Test Rabbit'),
      );

      expect(find.text('Test Rabbit'), findsOneWidget);
      expect(find.byType(InitialView), findsNothing);
      expect(find.byType(FailureView), findsNothing);
      expect(find.byType(RabbitNotesListView), findsOneWidget);
      expect(find.byKey(const Key('errorSnackBar')), findsNothing);
    });

    testWidgets(
        'should render rabbit notes list view without rabbit name when state is RabbitNotesListSuccess',
        (WidgetTester tester) async {
      when(() => rabbitNotesListBloc.state).thenReturn(
        const RabbitNotesListSuccess(
          rabbitNotes: [
            RabbitNote(
              id: 1,
              description: 'Test note',
            ),
          ],
          hasReachedMax: true,
          totalCount: 1,
        ),
      );

      await tester.pumpWidget(
        buildWidget(name: null),
      );

      expect(find.text('Historia Notatek'), findsOneWidget);
      expect(find.byType(InitialView), findsNothing);
      expect(find.byType(FailureView), findsNothing);
      expect(find.byType(RabbitNotesListView), findsOneWidget);
      expect(find.byKey(const Key('errorSnackBar')), findsNothing);
    });

    testWidgets('should open filter dialog when filter button is pressed',
        (WidgetTester tester) async {
      when(() => rabbitNotesListBloc.state).thenReturn(
        const RabbitNotesListSuccess(
          rabbitNotes: [
            RabbitNote(
              id: 1,
              description: 'Test note',
            ),
          ],
          hasReachedMax: true,
          totalCount: 1,
        ),
      );
      when(() => rabbitNotesListBloc.args)
          .thenReturn(const FindRabbitNotesArgs(rabbitId: 1));

      await tester.pumpWidget(
        buildWidget(name: 'Test Rabbit'),
      );

      await tester.tap(find.byKey(const Key('filterAction')));
      await tester.pumpAndSettle();

      expect(find.byType(BottomSheet), findsOneWidget);
    });
  });
}
