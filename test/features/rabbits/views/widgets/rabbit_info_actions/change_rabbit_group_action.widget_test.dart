import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:spk_app_frontend/features/rabbits/bloc/rabbit_update.cubit.dart';
import 'package:spk_app_frontend/features/rabbits/bloc/rabbits_list.bloc.dart';
import 'package:spk_app_frontend/features/rabbits/models/models.dart';
import 'package:spk_app_frontend/features/rabbits/views/widgets/rabbit_info_actions/change_rabbit_group_action.widget.dart';

class MockRabbitsListBloc extends MockBloc<RabbitsListEvent, RabbitsListState>
    implements RabbitsListBloc {}

class MockRabbitUpdateCubit extends MockCubit<RabbitUpdateState>
    implements RabbitUpdateCubit {}

class MockGoRouter extends Mock implements GoRouter {}

void main() {
  group(ChangeRabbitGroupAction, () {
    late RabbitsListBloc rabbitsListBloc;
    late RabbitUpdateCubit rabbitUpdateCubit;
    late GoRouter goRouter;

    const rabbitGroup1 = RabbitGroup(
      id: '1',
      rabbits: [
        Rabbit(
          id: '1',
          name: 'Rabbit 1',
          gender: Gender.female,
          admissionType: AdmissionType.found,
          confirmedBirthDate: false,
        ),
      ],
    );
    const rabbitGroup2 = RabbitGroup(id: '2', rabbits: [
      Rabbit(
        id: '2',
        name: 'Rabbit 2',
        gender: Gender.female,
        admissionType: AdmissionType.found,
        confirmedBirthDate: false,
      )
    ]);

    const rabbit = Rabbit(
      id: '1',
      name: 'Rabbit 1',
      gender: Gender.female,
      admissionType: AdmissionType.found,
      confirmedBirthDate: false,
      rabbitGroup: rabbitGroup1,
    );

    setUp(() {
      rabbitsListBloc = MockRabbitsListBloc();
      rabbitUpdateCubit = MockRabbitUpdateCubit();
      goRouter = MockGoRouter();

      when(() => rabbitsListBloc.state).thenAnswer(
        (_) => const RabbitsListSuccess(
          rabbitGroups: [
            rabbitGroup1,
            rabbitGroup2,
          ],
          hasReachedMax: true,
          totalCount: 2,
        ),
      );
      when(() => rabbitUpdateCubit.state).thenAnswer(
        (_) => const RabbitUpdateInitial(),
      );
    });

    Widget buildWidget({Rabbit rabbit = rabbit}) {
      return MaterialApp(
        home: InheritedGoRouter(
          goRouter: goRouter,
          child: Scaffold(
            body: ChangeRabbitGroupAction(
              rabbit: rabbit,
              rabbitsListBloc: (_) => rabbitsListBloc,
              rabbitUpdateCubit: (_) => rabbitUpdateCubit,
            ),
          ),
        ),
      );
    }

    group('renders', () {
      testWidgets('renders correctly', (WidgetTester tester) async {
        await tester.pumpWidget(buildWidget());

        expect(find.text('Wybierz nową grupę zaprzyjaźnionych królików'),
            findsOneWidget);
        expect(find.byType(DropdownButton<int>), findsOneWidget);
        expect(find.byType(FilledButton), findsOneWidget);

        expect(find.text(rabbitGroup1.name), findsOneWidget);
        expect(find.text(rabbitGroup2.name), findsNothing);
      });

      testWidgets('changes rabbit group on dropdown selection',
          (WidgetTester tester) async {
        await tester.pumpWidget(buildWidget());

        await tester.tap(find.byType(DropdownButton<int>));
        await tester.pumpAndSettle();

        await tester.tap(find.text(rabbitGroup2.name));
        await tester.pumpAndSettle();

        expect(find.text(rabbitGroup1.name), findsNothing);
        expect(find.text(rabbitGroup2.name), findsOneWidget);
      });

      testWidgets('should display CircularProgressIndicator when loading',
          (WidgetTester tester) async {
        when(() => rabbitsListBloc.state).thenAnswer(
          (_) => const RabbitsListInitial(),
        );

        await tester.pumpWidget(buildWidget());

        expect(find.byType(CircularProgressIndicator), findsOneWidget);
      });

      testWidgets('should display error message when loading failed',
          (WidgetTester tester) async {
        when(() => rabbitsListBloc.state).thenAnswer(
          (_) => const RabbitsListFailure(),
        );

        await tester.pumpWidget(buildWidget());

        expect(find.text('Nie udało się pobrać listy grup królików'),
            findsOneWidget);
      });

      testWidgets('should refresh button works when loading failed',
          (WidgetTester tester) async {
        when(() => rabbitsListBloc.state).thenAnswer(
          (_) => const RabbitsListFailure(),
        );

        await tester.pumpWidget(buildWidget());

        await tester.tap(find.text('Spróbuj ponownie'));
        await tester.pumpAndSettle();

        verify(() => rabbitsListBloc.add(const FetchRabbits())).called(1);
      });

      testWidgets('should display AlertDialog on save button press',
          (WidgetTester tester) async {
        await tester.pumpWidget(buildWidget());

        await tester.tap(find.byType(DropdownButton<int>));
        await tester.pumpAndSettle();

        await tester.tap(find.text(rabbitGroup2.name));
        await tester.pumpAndSettle();

        await tester.tap(find.byType(FilledButton));
        await tester.pumpAndSettle();

        expect(find.byType(AlertDialog), findsOneWidget);
      });
    });

    group('save', () {
      testWidgets('calls RabbitUpdateCubit.changeRabbitGroup on button press',
          (WidgetTester tester) async {
        whenListen(
          rabbitUpdateCubit,
          Stream.fromIterable([
            const RabbitUpdated(),
          ]),
          initialState: const RabbitUpdateInitial(),
        );

        await tester.pumpWidget(buildWidget());

        await tester.tap(find.byType(DropdownButton<int>));
        await tester.pumpAndSettle();

        await tester.tap(find.text(rabbitGroup2.name));
        await tester.pumpAndSettle();

        await tester.tap(find.byType(FilledButton));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Zmień'));
        await tester.pumpAndSettle();

        expect(find.text('Zapisano zmiany'), findsOneWidget);

        verify(() => rabbitUpdateCubit.changeRabbitGroup(
              rabbit.id,
              rabbitGroup2.id,
            )).called(1);
        verify(() => goRouter.pop(true)).called(1);
      });

      testWidgets('cancel button works', (WidgetTester tester) async {
        whenListen(
          rabbitUpdateCubit,
          Stream.fromIterable([
            const RabbitUpdated(),
          ]),
          initialState: const RabbitUpdateInitial(),
        );

        await tester.pumpWidget(buildWidget());

        await tester.tap(find.byType(DropdownButton<int>));
        await tester.pumpAndSettle();

        await tester.tap(find.text(rabbitGroup2.name));
        await tester.pumpAndSettle();

        await tester.tap(find.byType(FilledButton));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Anuluj'));
        await tester.pumpAndSettle();

        verifyNever(() => rabbitUpdateCubit.changeRabbitGroup(
              rabbit.id,
              rabbitGroup2.id,
            ));
        verify(() => goRouter.pop()).called(1);
      });

      testWidgets('save without changing group', (WidgetTester tester) async {
        await tester.pumpWidget(buildWidget());

        await tester.tap(find.byType(FilledButton));
        await tester.pump();

        expect(find.text('Nie zmieniono grupy królika'), findsOneWidget);

        verifyNever(() => rabbitUpdateCubit.changeRabbitGroup(any(), any()));
        verify(() => goRouter.pop()).called(1);
      });

      testWidgets('show snackbar when RabbitUpdateCubit fails',
          (WidgetTester tester) async {
        whenListen(
          rabbitUpdateCubit,
          Stream.fromIterable([
            const RabbitUpdateFailure(),
          ]),
          initialState: const RabbitUpdateInitial(),
        );

        await tester.pumpWidget(buildWidget());

        await tester.tap(find.byType(FilledButton));
        await tester.pump();

        expect(
            find.text('Nie udało się zmienić grupy królika'), findsOneWidget);
      });
    });
  });
}
