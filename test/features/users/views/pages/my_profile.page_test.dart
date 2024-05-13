import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';

import 'package:spk_app_frontend/common/views/views.dart';
import 'package:spk_app_frontend/features/auth/auth.dart';
import 'package:spk_app_frontend/features/auth/bloc/send_verification_mail.cubit.dart';
import 'package:spk_app_frontend/features/users/bloc/user.cubit.dart';
import 'package:spk_app_frontend/features/users/models/models.dart';
import 'package:spk_app_frontend/features/users/views/pages/my_profile.page.dart';
import 'package:spk_app_frontend/features/users/views/views/user.view.dart';

class MockUserCubit extends MockCubit<UserState> implements UserCubit {}

class MockSendVerificationMailCubit extends MockCubit<SendVerificationMailState>
    implements SendVerificationMailCubit {}

class MockAuthCubit extends MockCubit<AuthState> implements AuthCubit {}

class MockGoRouter extends Mock implements GoRouter {}

void main() {
  group(MyProfilePage, () {
    late UserCubit userCubit;
    late SendVerificationMailCubit sendVerificationMailCubit;
    late AuthCubit authCubit;
    late GoRouter goRouter;

    setUp(() {
      userCubit = MockUserCubit();
      sendVerificationMailCubit = MockSendVerificationMailCubit();
      authCubit = MockAuthCubit();
      goRouter = MockGoRouter();

      when(() => userCubit.state).thenReturn(
        const UserSuccess(
            user: User(id: '1', firstName: 'John', lastName: 'Doe')),
      );
      when(() => sendVerificationMailCubit.state).thenReturn(
        const SendVerificationMailInitial(),
      );

      when(() => authCubit.currentUser).thenReturn(
        CurrentUser(
          uid: '123',
          token: 'token',
          roles: const [],
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
            child: MyProfilePage(
              userCubit: (_) => userCubit,
              sendVerificationMailCubit: (_) => sendVerificationMailCubit,
            ),
          ),
        ),
      );
    }

    testWidgets('renders InitialView when UserInitial state is received',
        (WidgetTester tester) async {
      when(() => userCubit.state).thenReturn(const UserInitial());

      await tester.pumpWidget(buildWidget());

      expect(find.byType(InitialView), findsOneWidget);
      expect(find.byType(FailureView), findsNothing);
      expect(find.byType(UserView), findsNothing);
    });

    testWidgets('renders FailureView when UserFailure state is received',
        (WidgetTester tester) async {
      when(() => userCubit.state).thenReturn(const UserFailure());

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
      expect(find.byKey(const Key('emailVerificationError')), findsNothing);
    });

    testWidgets('renders not verified message when email is not verified',
        (WidgetTester tester) async {
      when(() => authCubit.currentUser).thenReturn(
        CurrentUser(
          uid: '123',
          token: 'token',
          roles: const [],
          emailVerified: false,
        ),
      );

      await tester.pumpWidget(buildWidget());

      expect(find.byKey(const Key('emailVerificationError')), findsOneWidget);
    });
  });
}
