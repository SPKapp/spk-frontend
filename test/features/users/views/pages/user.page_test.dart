import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:spk_app_frontend/common/bloc/interfaces/get_one.cubit.interface.dart';

import 'package:spk_app_frontend/common/views/views.dart';
import 'package:spk_app_frontend/features/auth/auth.dart';
import 'package:spk_app_frontend/features/users/bloc/user.cubit.dart';
import 'package:spk_app_frontend/features/users/models/models.dart';

import 'package:spk_app_frontend/features/users/views/pages/user.page.dart';
import 'package:spk_app_frontend/features/users/views/views/user.view.dart';

class MockUserCubit extends MockCubit<GetOneState<User>> implements UserCubit {}

class MockAuthCubit extends MockCubit<AuthState> implements AuthCubit {}

class MockGoRouter extends Mock implements GoRouter {
  @override
  bool canPop() {
    return false;
  }
}

void main() {
  group(UserPage, () {
    late UserCubit userCubit;
    late AuthCubit authCubit;
    late GoRouter goRouter;

    setUp(() {
      userCubit = MockUserCubit();
      authCubit = MockAuthCubit();
      goRouter = MockGoRouter();

      when(() => userCubit.state).thenReturn(
        const GetOneSuccess(
            data: User(
                id: '1', firstName: 'John', lastName: 'Doe', active: true)),
      );
      when(() => authCubit.currentUser).thenReturn(
        CurrentUser(
          uid: '123',
          token: 'token',
          roles: const [Role.admin],
          emailVerified: true,
        ),
      );
    });

    Widget buildWidget() {
      return MaterialApp(
        home: InheritedGoRouter(
          goRouter: goRouter,
          child: BlocProvider.value(
            value: authCubit,
            child: UserPage(
              userId: '1',
              userCubit: (_) => userCubit,
            ),
          ),
        ),
      );
    }

    testWidgets('renders InitialView when UserInitial state is received',
        (WidgetTester tester) async {
      when(() => userCubit.state).thenReturn(const GetOneInitial());

      await tester.pumpWidget(buildWidget());

      expect(find.byType(InitialView), findsOneWidget);
      expect(find.byType(FailureView), findsNothing);
      expect(find.byType(UserView), findsNothing);
    });

    testWidgets('renders FailureView when UserFailure state is received',
        (WidgetTester tester) async {
      when(() => userCubit.state).thenReturn(const GetOneFailure());

      await tester.pumpWidget(buildWidget());

      expect(find.byType(InitialView), findsNothing);
      expect(find.byType(FailureView), findsOneWidget);
      expect(find.byType(UserView), findsNothing);
    });

    testWidgets('renders UserView when UserSuccess state is received',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildWidget());

      expect(find.byType(InitialView), findsNothing);
      expect(find.byType(FailureView), findsNothing);
      expect(find.byType(UserView), findsOneWidget);
    });

    testWidgets('should display active user actions when user is active',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildWidget());

      expect(find.byKey(const Key('editUser')), findsOneWidget);

      await tester.tap(find.byKey(const Key('userPopupMenu')));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('addRole')), findsOneWidget);
      expect(find.byKey(const Key('removeRole')), findsOneWidget);
      expect(find.byKey(const Key('changeRegion')), findsOneWidget);
      expect(find.byKey(const Key('deactivateUser')), findsOneWidget);
      expect(find.text('Dezaktywuj'), findsOneWidget);
      expect(find.byKey(const Key('deleteUser')), findsNothing);
    });

    testWidgets('should display inactive user actions when user is inactive',
        (WidgetTester tester) async {
      when(() => userCubit.state).thenReturn(
        const GetOneSuccess(
          data:
              User(id: '1', firstName: 'John', lastName: 'Doe', active: false),
        ),
      );

      await tester.pumpWidget(buildWidget());

      expect(find.byKey(const Key('editUser')), findsNothing);

      await tester.tap(find.byKey(const Key('userPopupMenu')));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('addRole')), findsNothing);
      expect(find.byKey(const Key('removeRole')), findsOneWidget);
      expect(find.byKey(const Key('changeRegion')), findsNothing);
      expect(find.byKey(const Key('deactivateUser')), findsOneWidget);
      expect(find.text('Aktywuj'), findsOneWidget);
      expect(find.byKey(const Key('deleteUser')), findsOneWidget);
    });

    testWidgets('should display user actions when user is not admin',
        (WidgetTester tester) async {
      when(() => authCubit.currentUser).thenReturn(
        CurrentUser(
          uid: '123',
          token: 'token',
          roles: const [Role.regionManager],
          managerRegions: const [1],
          emailVerified: true,
        ),
      );

      await tester.pumpWidget(buildWidget());

      expect(find.byKey(const Key('editUser')), findsOneWidget);

      await tester.tap(find.byKey(const Key('userPopupMenu')));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('addRole')), findsOneWidget);
      expect(find.byKey(const Key('removeRole')), findsOneWidget);
      expect(find.byKey(const Key('changeRegion')), findsNothing);
      expect(find.byKey(const Key('deactivateUser')), findsOneWidget);
      expect(find.text('Dezaktywuj'), findsOneWidget);
      expect(find.byKey(const Key('deleteUser')), findsNothing);
    });
  });
}
