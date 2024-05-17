import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:spk_app_frontend/features/auth/auth.dart';
import 'package:spk_app_frontend/features/regions/bloc/regions_list.bloc.dart';
import 'package:spk_app_frontend/features/regions/models/models.dart';
import 'package:spk_app_frontend/features/users/bloc/user_actions/user_permissions.cubit.dart';
import 'package:spk_app_frontend/features/users/models/models.dart';

import 'package:spk_app_frontend/features/users/views/widgets/user_actions/remove_role_action.widget.dart';

class MockRegionsListBloc extends MockCubit<RegionsListState>
    implements RegionsListBloc {}

class MockUserPermissionsCubit extends MockCubit<UserPermissionsState>
    implements UserPermissionsCubit {}

class MockAuthCubit extends MockCubit<AuthState> implements AuthCubit {}

class MockGoRouter extends Mock implements GoRouter {}

void main() {
  group(RemoveRoleAction, () {
    late RegionsListBloc regionsListBloc;
    late UserPermissionsCubit userPermissionsCubit;
    late AuthCubit authCubit;
    late GoRouter goRouter;

    setUp(() {
      regionsListBloc = MockRegionsListBloc();
      userPermissionsCubit = MockUserPermissionsCubit();
      authCubit = MockAuthCubit();
      goRouter = MockGoRouter();

      when(() => authCubit.currentUser).thenReturn(
        CurrentUser(uid: '123', token: '123', roles: const [Role.admin]),
      );

      when(() => regionsListBloc.state).thenReturn(
        const RegionsListSuccess(
          regions: [Region(id: '1', name: 'Region 1')],
          hasReachedMax: true,
          totalCount: 1,
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
              body: RemoveRoleAction(
                userId: '1',
                roleInfo: roleInfo,
                regionsListBloc: (context) => regionsListBloc,
                userPermissionsCubit: (context) => userPermissionsCubit,
              ),
            ),
          ),
        ),
      );
    }

    testWidgets('renders RemoveRoleAction', (tester) async {
      await tester.pumpWidget(buildwidget(
        roleInfo: RoleInfo([]),
      ));

      expect(find.text('Brak ról do usunięcia'), findsOneWidget);
    });

    testWidgets('not render admin role', (tester) async {
      when(() => authCubit.currentUser).thenReturn(
        CurrentUser(
            uid: '123',
            token: '123',
            roles: const [Role.regionManager],
            managerRegions: const [1]),
      );

      await tester.pumpWidget(buildwidget(
        roleInfo: RoleInfo([const RoleEntity(role: Role.admin)]),
      ));

      expect(find.text('Usuń rolę'), findsOneWidget);

      await tester.tap(find.byKey(const Key('roleDropdown')));
      await tester.pumpAndSettle();

      expect(find.text(Role.admin.displayName), findsNothing);
    });

    testWidgets('render admin role', (tester) async {
      await tester.pumpWidget(buildwidget(
        roleInfo: RoleInfo([const RoleEntity(role: Role.admin)]),
      ));

      expect(find.text('Usuń rolę'), findsOneWidget);

      await tester.tap(find.byKey(const Key('roleDropdown')));
      await tester.pumpAndSettle();

      expect(find.text(Role.admin.displayName), findsAny);
    });

    testWidgets('display region dropdown', (tester) async {
      await tester.pumpWidget(buildwidget(
        roleInfo: RoleInfo(
            [const RoleEntity(role: Role.regionManager, additionalInfo: '1')]),
      ));

      await tester.tap(find.byKey(const Key('roleDropdown')));
      await tester.pumpAndSettle();

      expect(find.text(Role.regionManager.displayName), findsAny);
    });

    testWidgets('click delete role', (tester) async {
      when(() => userPermissionsCubit.removeRoleFromUser(
            Role.regionManager,
          )).thenAnswer((_) async => {});

      await tester.pumpWidget(buildwidget(
        roleInfo: RoleInfo(
            [const RoleEntity(role: Role.regionManager, additionalInfo: '1')]),
      ));

      await tester.tap(find.byKey(const Key('roleDropdown')));
      await tester.pumpAndSettle();

      await tester.tap(find.text(Role.regionManager.displayName).last);
      await tester.pumpAndSettle();

      await tester.tap(find.byType(FilledButton));
      await tester.pumpAndSettle();

      verify(() => userPermissionsCubit.removeRoleFromUser(
            Role.regionManager,
          )).called(1);
    });

    testWidgets('click delete role without region', (tester) async {
      when(() => authCubit.currentUser).thenReturn(
        CurrentUser(
            uid: '123',
            token: '123',
            roles: const [Role.regionManager],
            managerRegions: const [1]),
      );
      when(() => userPermissionsCubit.removeRoleFromUser(
            Role.regionManager,
            regionId: '1',
          )).thenAnswer((_) async => {});

      await tester.pumpWidget(buildwidget(
        roleInfo: RoleInfo(
            [const RoleEntity(role: Role.regionManager, additionalInfo: '1')]),
      ));

      await tester.tap(find.byKey(const Key('roleDropdown')));
      await tester.pumpAndSettle();

      await tester.tap(find.text(Role.regionManager.displayName).last);
      await tester.pumpAndSettle();

      await tester.tap(find.byType(FilledButton));
      await tester.pumpAndSettle();

      expect(find.text('Wybierz region'), findsOne);

      verifyNever(() => userPermissionsCubit.removeRoleFromUser(Role.admin));
    });

    testWidgets('click delete without role', (tester) async {
      await tester.pumpWidget(buildwidget(
        roleInfo: RoleInfo([const RoleEntity(role: Role.admin)]),
      ));

      await tester.tap(find.byType(FilledButton));
      await tester.pumpAndSettle();

      expect(find.text('Wybierz rolę'), findsOne);

      verifyNever(() => userPermissionsCubit.removeRoleFromUser(Role.admin));
    });

    testWidgets('remove role', (tester) async {
      whenListen(
        userPermissionsCubit,
        Stream.fromIterable([
          const UserPermissionsSuccess(),
        ]),
        initialState: const UserPermissionsInitial(),
      );

      await tester.pumpWidget(buildwidget(
        roleInfo: RoleInfo([const RoleEntity(role: Role.admin)]),
      ));

      await tester.tap(find.byType(FilledButton));
      await tester.pump();

      expect(find.text('Rola usunięta'), findsOne);
      verify(() => goRouter.pop(true)).called(1);
    });

    testWidgets('remove role failure', (tester) async {
      whenListen(
        userPermissionsCubit,
        Stream.fromIterable([
          const UserPermissionsFailure(),
        ]),
        initialState: const UserPermissionsInitial(),
      );
      await tester.pumpWidget(buildwidget(
        roleInfo: RoleInfo([const RoleEntity(role: Role.admin)]),
      ));

      await tester.tap(find.byType(FilledButton));
      await tester.pump();

      expect(find.text('Nie udało się usunąć roli'), findsOne);
      verifyNever(() => goRouter.pop(true));
    });
  });
}
