import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:spk_app_frontend/common/views/views.dart';
import 'package:spk_app_frontend/features/auth/auth.dart';
import 'package:spk_app_frontend/features/regions/models/models.dart';
import 'package:spk_app_frontend/features/users/bloc/user_actions/regions_and_teams.cubit.dart';
import 'package:spk_app_frontend/features/users/bloc/user_actions/user_permissions.cubit.dart';
import 'package:spk_app_frontend/features/users/models/models.dart';

import 'package:spk_app_frontend/features/users/views/widgets/user_actions/add_role_action.widget.dart';

class MockRegionsAndTeamsCubit extends MockCubit<RegionsAndTeamsState>
    implements RegionsAndTeamsCubit {}

class MockUserPermissionsCubit extends MockCubit<UserPermissionsState>
    implements UserPermissionsCubit {}

class MockAuthCubit extends MockCubit<AuthState> implements AuthCubit {}

class MockGoRouter extends Mock implements GoRouter {}

void main() {
  group(AddRoleAction, () {
    late RegionsAndTeamsCubit regionsAndTeamsCubit;
    late UserPermissionsCubit userPermissionsCubit;
    late AuthCubit authCubit;
    late GoRouter goRouter;

    setUp(() {
      regionsAndTeamsCubit = MockRegionsAndTeamsCubit();
      userPermissionsCubit = MockUserPermissionsCubit();
      authCubit = MockAuthCubit();
      goRouter = MockGoRouter();

      when(() => authCubit.currentUser).thenReturn(
        CurrentUser(
            uid: '123',
            token: '123',
            roles: const [Role.regionManager],
            managerRegions: const [1]),
      );

      when(() => regionsAndTeamsCubit.state).thenReturn(
        const RegionsAndTeamsSuccess(
          regions: [Region(id: '1', name: 'Region 1')],
          teams: [Team(id: 1, users: [])],
        ),
      );

      when(() => userPermissionsCubit.state)
          .thenReturn(const UserPermissionsInitial());
    });

    Widget buildwidget({required RoleInfo roleInfo}) {
      return MaterialApp(
        home: InheritedGoRouter(
          goRouter: goRouter,
          child: BlocProvider.value(
            value: authCubit,
            child: Scaffold(
              body: AddRoleAction(
                userId: '1',
                roleInfo: roleInfo,
                regionsAndTeamsCubit: (_) => regionsAndTeamsCubit,
                userPermissionsCubit: (_) => userPermissionsCubit,
              ),
            ),
          ),
        ),
      );
    }

    group('UI Tests', () {
      testWidgets('renders correctly', (WidgetTester tester) async {
        await tester.pumpWidget(
          buildwidget(
            roleInfo: RoleInfo([]),
          ),
        );

        expect(find.text('Dodaj rolę'), findsOneWidget);
        expect(find.byKey(const Key('roleDropdown')), findsOneWidget);
        expect(find.byKey(const Key('regionDropdown')), findsNothing);
        expect(find.byKey(const Key('teamDropdown')), findsNothing);
        expect(find.byType(FilledButton), findsOneWidget);
      });

      testWidgets('display region dropdown', (WidgetTester tester) async {
        await tester.pumpWidget(
          buildwidget(
            roleInfo: RoleInfo([]),
          ),
        );

        await tester.tap(find.byKey(const Key('roleDropdown')));
        await tester.pumpAndSettle();

        expect(find.text(Role.admin.toHumanReadable()), findsNothing);
        expect(find.text(Role.volunteer.toHumanReadable()), findsAny);
        expect(find.text(Role.regionManager.toHumanReadable()), findsAny);
        expect(
            find.text(Role.regionRabbitObserver.toHumanReadable()), findsAny);

        await tester.tap(find.text(Role.regionManager.toHumanReadable()).last);
        await tester.pumpAndSettle();

        expect(find.byKey(const Key('regionDropdown')), findsOneWidget);
        expect(find.byKey(const Key('teamDropdown')), findsNothing);

        await tester.tap(find.byKey(const Key('regionDropdown')));
        await tester.pumpAndSettle();

        expect(find.text('Region 1'), findsAny);
      });

      testWidgets('display team dropdown', (WidgetTester tester) async {
        await tester.pumpWidget(
          buildwidget(
            roleInfo: RoleInfo([]),
          ),
        );

        await tester.tap(find.byKey(const Key('roleDropdown')));
        await tester.pumpAndSettle();

        await tester.tap(find.text(Role.volunteer.toHumanReadable()).last);
        await tester.pumpAndSettle();

        expect(find.byKey(const Key('regionDropdown')), findsOneWidget);
        expect(find.byKey(const Key('teamDropdown')), findsOneWidget);

        await tester.tap(find.byKey(const Key('teamDropdown')));
        await tester.pumpAndSettle();

        expect(find.text('Nowy zespół'), findsAny);
      });

      testWidgets('not display region and team dropdown',
          (WidgetTester tester) async {
        when(() => authCubit.currentUser).thenReturn(
          CurrentUser(uid: '123', token: '123', roles: const [Role.admin]),
        );
        await tester.pumpWidget(
          buildwidget(
            roleInfo: RoleInfo([]),
          ),
        );

        await tester.tap(find.byKey(const Key('roleDropdown')));
        await tester.pumpAndSettle();

        await tester.tap(find.text(Role.admin.toHumanReadable()).last);
        await tester.pumpAndSettle();

        expect(find.byKey(const Key('regionDropdown')), findsNothing);
        expect(find.byKey(const Key('teamDropdown')), findsNothing);
      });

      testWidgets('not display regionObserver and adminRoles',
          (WidgetTester tester) async {
        when(() => authCubit.currentUser).thenReturn(
          CurrentUser(uid: '123', token: '123', roles: const [Role.admin]),
        );

        await tester.pumpWidget(
          buildwidget(
            roleInfo: RoleInfo([
              const RoleEntity(role: Role.admin),
              const RoleEntity(
                  role: Role.regionRabbitObserver, additionalInfo: '1'),
            ]),
          ),
        );

        await tester.tap(find.byKey(const Key('roleDropdown')));
        await tester.pumpAndSettle();

        expect(find.text(Role.admin.toHumanReadable()), findsNothing);
        expect(find.text(Role.volunteer.toHumanReadable()), findsAny);
        expect(find.text(Role.regionManager.toHumanReadable()), findsAny);
        expect(find.text(Role.regionRabbitObserver.toHumanReadable()),
            findsNothing);
      });
    });

    group('fetchRegionsAndTeams', () {
      testWidgets('display InitialView when RegionsAndTeamsInitial',
          (WidgetTester tester) async {
        when(() => regionsAndTeamsCubit.state).thenReturn(
          const RegionsAndTeamsInitial(),
        );
        await tester.pumpWidget(
          buildwidget(
            roleInfo: RoleInfo([]),
          ),
        );

        expect(find.byType(InitialView), findsOneWidget);
        expect(find.byType(FailureView), findsNothing);
        expect(find.byKey(const Key('roleDropdown')), findsNothing);
      });

      testWidgets('display FailureView when RegionsAndTeamsFailure',
          (WidgetTester tester) async {
        when(() => regionsAndTeamsCubit.state).thenReturn(
          const RegionsAndTeamsFailure(),
        );

        await tester.pumpWidget(
          buildwidget(
            roleInfo: RoleInfo([]),
          ),
        );

        expect(find.byType(FailureView), findsOneWidget);
        expect(find.byType(InitialView), findsNothing);
        expect(find.byKey(const Key('roleDropdown')), findsNothing);
      });
    });

    group('Logic Tests', () {
      testWidgets('Dispaly No Role Error', (WidgetTester tester) async {
        await tester.pumpWidget(
          buildwidget(
            roleInfo: RoleInfo([]),
          ),
        );

        await tester.tap(find.byType(FilledButton));
        await tester.pump();

        expect(find.text('Wybierz rolę'), findsOneWidget);
      });

      testWidgets('Dispaly No Region Error', (WidgetTester tester) async {
        await tester.pumpWidget(
          buildwidget(
            roleInfo: RoleInfo([]),
          ),
        );

        await tester.tap(find.byKey(const Key('roleDropdown')));
        await tester.pumpAndSettle();
        await tester.tap(find.text(Role.regionManager.toHumanReadable()).last);
        await tester.pumpAndSettle();

        await tester.tap(find.byType(FilledButton));
        await tester.pump();

        expect(find.text('Wybierz region'), findsOneWidget);
      });

      testWidgets('Dispaly Success SnackBar', (WidgetTester tester) async {
        whenListen(
          userPermissionsCubit,
          Stream.fromIterable([
            const UserPermissionsSuccess(),
          ]),
          initialState: const UserPermissionsInitial(),
        );

        await tester.pumpWidget(
          buildwidget(
            roleInfo: RoleInfo([]),
          ),
        );

        await tester.tap(find.byType(FilledButton));
        await tester.pump();

        expect(find.text('Rola dodana'), findsOneWidget);

        verify(() => goRouter.pop(true)).called(1);
      });

      testWidgets('Dispaly Failure SnackBar', (WidgetTester tester) async {
        whenListen(
          userPermissionsCubit,
          Stream.fromIterable([
            const UserPermissionsFailure(),
          ]),
          initialState: const UserPermissionsInitial(),
        );

        await tester.pumpWidget(
          buildwidget(
            roleInfo: RoleInfo([]),
          ),
        );

        await tester.tap(find.byType(FilledButton));
        await tester.pump();

        expect(find.text('Nie udało się dodać roli'), findsOneWidget);

        verifyNever(() => goRouter.pop(true));
      });
    });
  });
}
