import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:spk_app_frontend/common/bloc/interfaces/get_list.bloc.interface.dart';
import 'package:spk_app_frontend/features/auth/auth.dart';
import 'package:spk_app_frontend/features/regions/bloc/regions_list.bloc.dart';
import 'package:spk_app_frontend/features/regions/models/models.dart';

import 'package:spk_app_frontend/features/users/bloc/user_create.cubit.dart';
import 'package:spk_app_frontend/features/users/models/dto/user_create.dto.dart';
import 'package:spk_app_frontend/features/users/views/pages/user_create.page.dart';
import 'package:spk_app_frontend/features/users/views/views/user_modify.view.dart';

class MockUserCreateCubit extends MockCubit<UserCreateState>
    implements UserCreateCubit {}

class MockRegionsListBloc extends MockBloc<GetListEvent, GetListState<Region>>
    implements RegionsListBloc {}

class MockAuthCubit extends MockCubit<AuthState> implements AuthCubit {}

class MockGoRouter extends Mock implements GoRouter {}

void main() {
  group(UserCreatePage, () {
    late MockUserCreateCubit userCreateCubit;
    late RegionsListBloc regionsListBloc;
    late AuthCubit authCubit;
    late GoRouter goRouter;

    setUpAll(() {
      registerFallbackValue(
        UserCreateDto(
          firstname: 'John',
          lastname: 'Doe',
          email: 'email@example.com',
          phone: '123456789',
        ),
      );
    });

    setUp(() {
      userCreateCubit = MockUserCreateCubit();
      regionsListBloc = MockRegionsListBloc();
      authCubit = MockAuthCubit();
      goRouter = MockGoRouter();

      when(() => userCreateCubit.state)
          .thenAnswer((_) => const UserCreateInitial());

      when(() => authCubit.currentUser).thenAnswer(
        (_) => CurrentUser(
          uid: '1',
          token: 'token',
          roles: const [Role.regionManager],
          managerRegions: const [1],
        ),
      );
    });

    Widget buildWidget() {
      return MaterialApp(
        home: InheritedGoRouter(
          goRouter: goRouter,
          child: BlocProvider<AuthCubit>.value(
            value: authCubit,
            child: UserCreatePage(
              cubitCreate: (_) => userCreateCubit,
              regionsListBloc: (_) => regionsListBloc,
            ),
          ),
        ),
      );
    }

    testWidgets('UserCreatePage should render correctly',
        (WidgetTester tester) async {
      when(() => userCreateCubit.state)
          .thenAnswer((_) => const UserCreateInitial());

      await tester.pumpWidget(buildWidget());

      expect(find.text('Dodaj Użytkownika'), findsOneWidget);
      expect(find.byType(UserModifyView), findsOneWidget);
    });

    testWidgets('UserCreatePage should create user when save button is pressed',
        (widgetTester) async {
      final streamController = StreamController<UserCreateState>();
      whenListen(
        userCreateCubit,
        streamController.stream,
        initialState: const UserCreateInitial(),
      );
      when(() => goRouter.pushReplacement(any()))
          .thenAnswer((invocation) async => Object());

      await widgetTester.pumpWidget(buildWidget());

      await fillForm(widgetTester);

      final saveButton = find.byKey(const Key('saveButton'));
      expect(saveButton, findsOneWidget);
      expect(find.text('Użytkownik został dodany'), findsNothing);

      streamController.add(const UserCreated(userId: '1'));

      await widgetTester.tap(saveButton);
      await widgetTester.pump();

      verify(() => userCreateCubit.createUser(any())).called(1);

      expect(find.text('Użytkownik został dodany'), findsOneWidget);
      expect(find.text('Nie udało się dodać użytkownika'), findsNothing);
    });

    testWidgets('UserCreatePage should show error message when save fails',
        (widgetTester) async {
      final streamController = StreamController<UserCreateState>();
      whenListen(
        userCreateCubit,
        streamController.stream,
        initialState: const UserCreateInitial(),
      );

      when(() => userCreateCubit.state)
          .thenAnswer((invocation) => const UserCreateInitial());

      await widgetTester.pumpWidget(buildWidget());

      await fillForm(widgetTester);

      final saveButton = find.byKey(const Key('saveButton'));
      expect(saveButton, findsOneWidget);
      expect(find.text('Nie udało się dodać użytkownika'), findsNothing);

      streamController.add(const UserCreateFailure());

      await widgetTester.tap(saveButton);
      await widgetTester.pump();

      verify(() => userCreateCubit.createUser(any())).called(1);

      expect(find.text('Nie udało się dodać użytkownika'), findsOneWidget);
      expect(find.text('Użytkownik został dodany'), findsNothing);
    });

    testWidgets('UserCreatePage should show error message when form is invalid',
        (widgetTester) async {
      when(() => userCreateCubit.state)
          .thenAnswer((invocation) => const UserCreateInitial());
      when(() => userCreateCubit.state)
          .thenAnswer((invocation) => const UserCreateInitial());

      await widgetTester.pumpWidget(buildWidget());

      final saveButton = find.byKey(const Key('saveButton'));
      expect(saveButton, findsOneWidget);
      expect(find.text('Nie udało się dodać użytkownika'), findsNothing);

      await widgetTester.tap(saveButton);
      await widgetTester.pump();

      verifyNever(() => userCreateCubit.createUser(any()));

      expect(find.text('Nie udało się dodać użytkownika'), findsNothing);
      expect(find.text('Użytkownik został dodany'), findsNothing);
    });

    testWidgets('UserCreatePage should show form with selected region',
        (widgetTester) async {
      when(() => authCubit.currentUser).thenAnswer(
        (_) => CurrentUser(
          uid: '1',
          token: 'token',
          roles: const [Role.regionManager],
          managerRegions: const [1, 2],
        ),
      );

      when(() => regionsListBloc.state).thenAnswer(
        (_) => GetListSuccess(
          data: const [
            Region(id: '1', name: 'Region 1'),
            Region(id: '2', name: 'Region 2'),
          ],
          hasReachedMax: true,
          totalCount: 2,
        ),
      );

      await widgetTester.pumpWidget(buildWidget());

      expect(find.text('Dodaj Użytkownika'), findsOneWidget);
      expect(find.byType(UserModifyView), findsOneWidget);

      final regionDropdown = find.byKey(const Key('regionDropdown'));
      expect(regionDropdown, findsOneWidget);
    });
  });
}

Future<void> fillForm(WidgetTester tester) async {
  await tester.tap(find.byKey(const Key('firstnameTextField')));
  await tester.pump();
  await tester.enterText(find.byKey(const Key('firstnameTextField')), 'John');

  await tester.tap(find.byKey(const Key('lastnameTextField')));
  await tester.pump();
  await tester.enterText(find.byKey(const Key('lastnameTextField')), 'Doe');

  await tester.tap(find.byKey(const Key('emailTextField')));
  await tester.pump();
  await tester.enterText(
      find.byKey(const Key('emailTextField')), 'email@example.com');

  await tester.tap(find.byKey(const Key('phoneTextField')));
  await tester.pump();
  await tester.enterText(find.byKey(const Key('phoneTextField')), '123456789');
}
