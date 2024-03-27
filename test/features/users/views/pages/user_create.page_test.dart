import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:spk_app_frontend/features/users/bloc/user_create.cubit.dart';
import 'package:spk_app_frontend/features/users/models/dto/user_create.dto.dart';
import 'package:spk_app_frontend/features/users/views/pages/user_create.page.dart';
import 'package:spk_app_frontend/features/users/views/views/user_modify.view.dart';

class MockUserCreateCubit extends MockCubit<UserCreateState>
    implements UserCreateCubit {}

class MockGoRouter extends Mock implements GoRouter {}

void main() {
  group(UserCreatePage, () {
    final MockUserCreateCubit userCreateCubit = MockUserCreateCubit();
    final MockGoRouter mockGoRouter = MockGoRouter();

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

    testWidgets('UserCreatePage should render correctly',
        (WidgetTester tester) async {
      when(() => userCreateCubit.state)
          .thenAnswer((_) => const UserCreateInitial());

      await tester.pumpWidget(
        MaterialApp(
          home: UserCreatePage(
            cubitCreate: (_) => userCreateCubit,
          ),
        ),
      );

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
      when(() => mockGoRouter.pushReplacement(any()))
          .thenAnswer((invocation) async => Object());

      await widgetTester.pumpWidget(
        MaterialApp(
          home: InheritedGoRouter(
            goRouter: mockGoRouter,
            child: UserCreatePage(
              cubitCreate: (_) => userCreateCubit,
            ),
          ),
        ),
      );

      await fillForm(widgetTester);

      final saveButton = find.byKey(const Key('saveButton'));
      expect(saveButton, findsOneWidget);
      expect(find.text('Użytkownik został dodany'), findsNothing);

      streamController.add(const UserCreated(userId: 1));

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

      await widgetTester.pumpWidget(
        MaterialApp(
          home: UserCreatePage(
            cubitCreate: (_) => userCreateCubit,
          ),
        ),
      );

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

      await widgetTester.pumpWidget(
        MaterialApp(
          home: UserCreatePage(
            cubitCreate: (_) => userCreateCubit,
          ),
        ),
      );

      final saveButton = find.byKey(const Key('saveButton'));
      expect(saveButton, findsOneWidget);
      expect(find.text('Nie udało się dodać użytkownika'), findsNothing);

      await widgetTester.tap(saveButton);
      await widgetTester.pump();

      verifyNever(() => userCreateCubit.createUser(any()));

      expect(find.text('Nie udało się dodać użytkownika'), findsNothing);
      expect(find.text('Użytkownik został dodany'), findsNothing);
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
