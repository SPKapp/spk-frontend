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
    late final MockGoRouter mockGoRouter;

    setUpAll(() {
      registerFallbackValue(
        UserCreateDto(
          firstname: 'John',
          lastname: 'Doe',
          email: 'email@example.com',
          phone: '123456789',
        ),
      );
      mockGoRouter = MockGoRouter();
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
      whenListen(
        userCreateCubit,
        Stream.fromIterable([
          const UserCreated(userId: 1),
        ]),
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

      final saveButton = find.byKey(const Key('saveButton'));
      expect(saveButton, findsOneWidget);
      expect(find.text('Użytkownik został dodany'), findsNothing);

      await widgetTester.tap(saveButton);
      await widgetTester.pump();

      verify(() => userCreateCubit.createUser(any())).called(1);

      expect(find.text('Użytkownik został dodany'), findsOneWidget);
      expect(find.text('Nie udało się dodać użytkownika'), findsNothing);
    });

    testWidgets('UserCreatePage should show error message when save fails',
        (widgetTester) async {
      whenListen(
        userCreateCubit,
        Stream.fromIterable([
          const UserCreateFailure(),
          const UserCreateInitial(),
        ]),
        initialState: const UserCreateInitial(),
      );

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

      verify(() => userCreateCubit.createUser(any())).called(1);

      expect(find.text('Nie udało się dodać użytkownika'), findsOneWidget);
      expect(find.text('Użytkownik został dodany'), findsNothing);
    });
  });
}
