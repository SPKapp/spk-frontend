import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:spk_app_frontend/common/bloc/interfaces/get_list.bloc.interface.dart';

import 'package:spk_app_frontend/common/views/views.dart';
import 'package:spk_app_frontend/features/rabbit-notes/bloc/rabbit_notes_list.bloc.dart';
import 'package:spk_app_frontend/features/rabbit-notes/models/dto.dart';
import 'package:spk_app_frontend/features/rabbit-notes/models/models.dart';
import 'package:spk_app_frontend/features/rabbit-notes/views/pages/rabbit_notes_list.page.dart';
import 'package:spk_app_frontend/features/rabbit-notes/views/widgets/list_page/rabbit_notes_list_item.widget.dart';

class MockRabbitNotesListBloc
    extends MockBloc<GetListEvent, GetListState<RabbitNote>>
    implements RabbitNotesListBloc {}

class MockGoRouter extends Mock implements GoRouter {
  @override
  bool canPop() => false;
}

void main() {
  group(RabbitNotesListPage, () {
    late RabbitNotesListBloc rabbitNotesListBloc;
    late GoRouter goRouter;

    setUp(() {
      rabbitNotesListBloc = MockRabbitNotesListBloc();
      goRouter = MockGoRouter();
    });

    Widget buildWidget({String? name, bool? isVetVisit}) {
      return MaterialApp(
        home: InheritedGoRouter(
          goRouter: goRouter,
          child: RabbitNotesListPage(
            rabbitId: '1',
            rabbitName: name,
            isVetVisit: isVetVisit,
            rabbitNotesListBloc: (context) => rabbitNotesListBloc,
          ),
        ),
      );
    }

    testWidgets(
        'should render initial view when state is RabbitNotesListInitial',
        (WidgetTester tester) async {
      when(() => rabbitNotesListBloc.state).thenReturn(GetListInitial());

      await tester.pumpWidget(
        buildWidget(name: 'Test Rabbit'),
      );

      expect(find.text('Test Rabbit'), findsOneWidget);
      expect(find.byType(InitialView), findsOneWidget);
      expect(find.byType(FailureView), findsNothing);
      expect(find.byType(RabbitNoteListItem), findsNothing);
      expect(find.byKey(const Key('errorSnackBar')), findsNothing);
    });

    testWidgets('should render initial view without rabbit name',
        (WidgetTester tester) async {
      when(() => rabbitNotesListBloc.state).thenReturn(GetListInitial());

      await tester.pumpWidget(
        buildWidget(name: null),
      );

      expect(find.text('Historia Notatek'), findsOneWidget);
      expect(find.byType(InitialView), findsOneWidget);
      expect(find.byType(FailureView), findsNothing);
      expect(find.byType(RabbitNoteListItem), findsNothing);
      expect(find.byKey(const Key('errorSnackBar')), findsNothing);
    });

    testWidgets(
        'should render failure view when state is RabbitNotesListFailure and rabbit notes are empty',
        (WidgetTester tester) async {
      when(() => rabbitNotesListBloc.state).thenReturn(GetListFailure());

      await tester.pumpWidget(
        buildWidget(name: 'Test Rabbit'),
      );

      expect(find.text('Test Rabbit'), findsOneWidget);
      expect(find.byType(InitialView), findsNothing);
      expect(find.byType(FailureView), findsOneWidget);
      expect(find.byType(RabbitNoteListItem), findsNothing);
      expect(find.byKey(const Key('errorSnackBar')), findsNothing);
    });

    testWidgets(
        'should render failure view when state is RabbitNotesListFailure and rabbit notes are not empty',
        (WidgetTester tester) async {
      whenListen(
          rabbitNotesListBloc,
          Stream.fromIterable([
            GetListFailure(
              data: const [
                RabbitNote(
                  id: '1',
                  description: 'Test note',
                ),
              ],
              hasReachedMax: true,
              totalCount: 1,
            ),
          ]),
          initialState: GetListSuccess(
            data: const [
              RabbitNote(
                id: '1',
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
      expect(find.byType(RabbitNoteListItem), findsOneWidget);
      expect(find.byKey(const Key('errorSnackBar')), findsOneWidget);
    });

    testWidgets(
        'should render rabbit notes list view when state is RabbitNotesListSuccess',
        (WidgetTester tester) async {
      when(() => rabbitNotesListBloc.state).thenReturn(
        GetListSuccess(
          data: const [
            RabbitNote(
              id: '1',
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
      expect(find.byType(RabbitNoteListItem), findsOneWidget);
      expect(find.byKey(const Key('errorSnackBar')), findsNothing);
    });

    testWidgets(
        'should render rabbit notes list view without rabbit name when state is RabbitNotesListSuccess',
        (WidgetTester tester) async {
      when(() => rabbitNotesListBloc.state).thenReturn(
        GetListSuccess(
          data: const [
            RabbitNote(
              id: '1',
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
      expect(find.byType(RabbitNoteListItem), findsOneWidget);
      expect(find.byKey(const Key('errorSnackBar')), findsNothing);
    });

    testWidgets('should open filter dialog when filter button is pressed',
        (WidgetTester tester) async {
      when(() => rabbitNotesListBloc.state).thenReturn(
        GetListSuccess(
          data: const [
            RabbitNote(
              id: '1',
              description: 'Test note',
            ),
          ],
          hasReachedMax: true,
          totalCount: 1,
        ),
      );
      when(() => rabbitNotesListBloc.args)
          .thenReturn(const FindRabbitNotesArgs(rabbitId: '1'));

      await tester.pumpWidget(
        buildWidget(name: 'Test Rabbit'),
      );

      await tester.tap(find.byKey(const Key('filterAction')));
      await tester.pumpAndSettle();

      expect(find.byType(BottomSheet), findsOneWidget);
    });

    testWidgets(
        'should navigate to create note page when add note button is pressed',
        (WidgetTester tester) async {
      when(() => rabbitNotesListBloc.state).thenReturn(
        GetListSuccess(
          data: const [],
          hasReachedMax: true,
          totalCount: 0,
        ),
      );
      when(() => rabbitNotesListBloc.args)
          .thenReturn(const FindRabbitNotesArgs(rabbitId: '1'));

      when(
        () =>
            goRouter.push('/rabbit/1/note/create', extra: any(named: 'extra')),
      ).thenAnswer((_) async => Object());

      await tester.pumpWidget(
        buildWidget(name: 'Test Rabbit'),
      );

      await tester.tap(find.byKey(const Key('addNoteButton')));
      await tester.pumpAndSettle();

      verify(
        () => goRouter.push('/rabbit/1/note/create', extra: {
          'isVetVisit': false,
          'rabbitName': 'Test Rabbit',
        }),
      ).called(1);
    });

    testWidgets(
        'should navigate to create note page with isVetVisit extra when add note button is pressed',
        (WidgetTester tester) async {
      when(() => rabbitNotesListBloc.state).thenReturn(
        GetListSuccess(
          data: const [],
          hasReachedMax: true,
          totalCount: 0,
        ),
      );
      when(() => rabbitNotesListBloc.args).thenReturn(
          const FindRabbitNotesArgs(rabbitId: '1', isVetVisit: true));

      when(
        () =>
            goRouter.push('/rabbit/1/note/create', extra: any(named: 'extra')),
      ).thenAnswer((_) async => Object());

      await tester.pumpWidget(
        buildWidget(name: 'Test Rabbit', isVetVisit: true),
      );

      await tester.tap(find.byKey(const Key('addNoteButton')));
      await tester.pumpAndSettle();

      verify(
        () => goRouter.push('/rabbit/1/note/create', extra: {
          'isVetVisit': true,
          'rabbitName': 'Test Rabbit',
        }),
      ).called(1);
    });
  });
}
