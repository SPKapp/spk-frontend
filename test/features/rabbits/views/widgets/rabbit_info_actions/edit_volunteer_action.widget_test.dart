import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:spk_app_frontend/features/rabbits/bloc/rabbit_update.cubit.dart';
import 'package:spk_app_frontend/features/rabbits/models/models.dart';
import 'package:spk_app_frontend/features/rabbits/views/widgets/rabbit_info_actions/edit_volunteer_action.widget.dart';

import 'package:spk_app_frontend/features/users/bloc/users_list.bloc.dart';
import 'package:spk_app_frontend/features/users/models/models.dart';

class MockUsersListBloc extends MockBloc<UsersListEvent, UsersListState>
    implements UsersListBloc {}

class MockRabbitUpdateCubit extends MockCubit<RabbitUpdateState>
    implements RabbitUpdateCubit {}

class MockGoRouter extends Mock implements GoRouter {}

void main() {
  group(EditVolunteerAction, () {
    late UsersListBloc usersListBloc;
    late RabbitUpdateCubit rabbitUpdateCubit;
    late GoRouter goRouter;

    const team1 = Team(
      id: 1,
      users: [
        User(id: 1, firstName: 'User', lastName: 'User'),
      ],
    );
    const team2 = Team(
      id: 2,
      users: [User(id: 2, firstName: 'User2', lastName: 'User2')],
    );

    const rabbit = Rabbit(
      id: 1,
      name: 'Rabbit',
      gender: Gender.female,
      admissionType: AdmissionType.found,
      confirmedBirthDate: false,
      rabbitGroup: RabbitGroup(
        id: 1,
        rabbits: [],
        team: team1,
      ),
    );

    setUp(() {
      usersListBloc = MockUsersListBloc();
      rabbitUpdateCubit = MockRabbitUpdateCubit();
      goRouter = MockGoRouter();

      when(() => usersListBloc.state).thenAnswer(
        (_) => UsersListSuccess(
          teams: const [
            team1,
            team2,
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
            body: EditVolunteerAction(
              rabbit: rabbit,
              usersListBloc: (_) => usersListBloc,
              rabbitUpdateCubit: (_) => rabbitUpdateCubit,
            ),
          ),
        ),
      );
    }

    group('renders', () {
      testWidgets('renders correctly', (WidgetTester tester) async {
        await tester.pumpWidget(buildWidget());

        expect(find.text('Wybierz nowych opiekunów'), findsOneWidget);
        expect(find.byType(DropdownButton<Team>), findsOneWidget);
        expect(find.byType(FilledButton), findsOneWidget);

        expect(find.text(team1.name), findsOneWidget);
        expect(find.text(team2.name), findsNothing);
      });

      testWidgets('changes team on dropdown selection',
          (WidgetTester tester) async {
        await tester.pumpWidget(buildWidget());

        final dropdownButton = find.byType(DropdownButton<Team>);
        expect(dropdownButton, findsOneWidget);

        await tester.tap(dropdownButton);
        await tester.pumpAndSettle();

        final dropdownMenuItem = find.text(team2.name);
        expect(dropdownMenuItem, findsOneWidget);

        await tester.tap(dropdownMenuItem);
        await tester.pumpAndSettle();

        expect(find.text(team1.name), findsNothing);
        expect(find.text(team2.name), findsOneWidget);
      });

      testWidgets('should display CircularProgressIndicator when loading',
          (WidgetTester tester) async {
        when(() => usersListBloc.state).thenAnswer(
          (_) => UsersListInitial(),
        );

        await tester.pumpWidget(buildWidget());

        expect(find.byType(CircularProgressIndicator), findsOneWidget);
      });

      testWidgets('should display error message when UsersListBloc fails',
          (WidgetTester tester) async {
        when(() => usersListBloc.state).thenAnswer(
          (_) => UsersListFailure(),
        );

        await tester.pumpWidget(buildWidget());

        expect(
            find.text('Nie udało się pobrać listy opiekunów'), findsOneWidget);
      });

      testWidgets('should refresh button works when UsersListBloc fails',
          (WidgetTester tester) async {
        when(() => usersListBloc.state).thenAnswer(
          (_) => UsersListFailure(),
        );

        await tester.pumpWidget(buildWidget());

        final refreshButton = find.text('Spróbuj ponownie');
        expect(refreshButton, findsOneWidget);

        await tester.tap(refreshButton);
        await tester.pumpAndSettle();

        verify(() => usersListBloc.add(const FetchUsers())).called(1);
      });
    });

    group('save', () {
      testWidgets('calls RabbitUpdateCubit.changeTeam on button press',
          (WidgetTester tester) async {
        whenListen(
          rabbitUpdateCubit,
          Stream.fromIterable([
            const RabbitUpdated(),
          ]),
          initialState: const RabbitUpdateInitial(),
        );

        await tester.pumpWidget(buildWidget());

        final dropdownButton = find.byType(DropdownButton<Team>);
        expect(dropdownButton, findsOneWidget);

        await tester.tap(dropdownButton);
        await tester.pumpAndSettle();

        final dropdownMenuItem = find.text(team2.name);
        expect(dropdownMenuItem, findsOneWidget);

        await tester.tap(dropdownMenuItem);
        await tester.pumpAndSettle();

        final saveButton = find.byType(FilledButton);
        expect(saveButton, findsOneWidget);

        await tester.tap(saveButton);
        await tester.pump();

        expect(find.text('Zapisano zmiany'), findsOneWidget);

        verify(() => rabbitUpdateCubit.changeTeam(
              rabbit.rabbitGroup!.id,
              team2.id,
            )).called(1);
        verify(() => goRouter.pop(true)).called(1);
      });

      testWidgets('save without change team', (WidgetTester tester) async {
        when(() => goRouter.pop(true)).thenAnswer((_) => Object());

        await tester.pumpWidget(buildWidget());

        final saveButton = find.byType(FilledButton);
        expect(saveButton, findsOneWidget);

        await tester.tap(saveButton);
        await tester.pump();

        verifyNever(() => rabbitUpdateCubit.changeTeam(
              rabbit.rabbitGroup!.id,
              rabbit.rabbitGroup!.team!.id,
            ));

        expect(find.text('Nie zmieniono opiekuna'), findsOneWidget);
        verify(() => goRouter.pop(true)).called(1);
      });

      testWidgets('shows snackbar when no team selected',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          buildWidget(
            rabbit: const Rabbit(
              id: 1,
              name: 'Rabbit',
              gender: Gender.female,
              admissionType: AdmissionType.found,
              confirmedBirthDate: false,
              rabbitGroup: RabbitGroup(
                id: 1,
                rabbits: [],
              ),
            ),
          ),
        );

        final saveButton = find.byType(FilledButton);
        expect(saveButton, findsOneWidget);

        await tester.tap(saveButton);
        await tester.pump();

        expect(find.text('Nie wybrano nowego opiekuna'), findsOneWidget);
      });

      testWidgets('shows snackbar when RabbitUpdateCubit fails',
          (WidgetTester tester) async {
        whenListen(
          rabbitUpdateCubit,
          Stream.fromIterable([
            const RabbitUpdateFailure(),
          ]),
          initialState: const RabbitUpdateInitial(),
        );

        await tester.pumpWidget(buildWidget());

        final dropdownButton = find.byType(DropdownButton<Team>);
        expect(dropdownButton, findsOneWidget);

        await tester.tap(dropdownButton);
        await tester.pumpAndSettle();

        final dropdownMenuItem = find.text(team2.name);
        expect(dropdownMenuItem, findsOneWidget);

        await tester.tap(dropdownMenuItem);
        await tester.pumpAndSettle();

        final saveButton = find.byType(FilledButton);
        expect(saveButton, findsOneWidget);

        await tester.tap(saveButton);
        await tester.pumpAndSettle();

        expect(find.text('Nie udało się zmienić opiekuna'), findsOneWidget);
        verifyNever(() => goRouter.pop(true));
      });
    });
  });
}
