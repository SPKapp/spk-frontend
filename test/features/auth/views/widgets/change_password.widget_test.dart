import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';

import 'package:spk_app_frontend/features/auth/bloc/change_password.cubit.dart';
import 'package:spk_app_frontend/features/auth/views/widgets/change_password.widget.dart';

class MockChangePasswordCubit extends MockCubit<PasswordChangeState>
    implements ChangePasswordCubit {}

class MockGoRouter extends Mock implements GoRouter {}

void main() {
  group(ChangePasswordAction, () {
    late MockChangePasswordCubit changePasswordCubit;
    late GoRouter goRouter;

    setUp(() {
      changePasswordCubit = MockChangePasswordCubit();
      goRouter = MockGoRouter();

      when(() => changePasswordCubit.state)
          .thenReturn(const PasswordChangeInitial());
    });

    Widget buildWidget() {
      return MaterialApp(
        home: InheritedGoRouter(
          goRouter: goRouter,
          child: Scaffold(
            body: ChangePasswordAction(
              changePasswordCubit: (_) => changePasswordCubit,
            ),
          ),
        ),
      );
    }

    testWidgets('Renders all form fields correctly',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildWidget());

      expect(find.text('Zmiana hasła'), findsOneWidget);
      expect(find.text('Stare Hasło'), findsOneWidget);
      expect(find.text('Nowe Hasło'), findsOneWidget);
      expect(find.text('Powtórz Hasło'), findsOneWidget);
      expect(find.byType(FilledButton), findsOneWidget);
    });

    testWidgets('Shows error messages for invalid input',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildWidget());

      await tester.enterText(
          find.byKey(const Key('newPasswordField')), 'short');
      await tester.enterText(
          find.byKey(const Key('confirmPasswordField')), 'mismatch');

      await tester.tap(find.text('Zapisz'));
      await tester.pump();

      expect(find.text('Hasło zbyt krótkie'), findsOneWidget);
      expect(find.text('Hasła nie pasują do siebie'), findsOneWidget);
    });

    testWidgets('Shows error when old password is wrong',
        (WidgetTester tester) async {
      whenListen(
        changePasswordCubit,
        Stream.fromIterable([
          const PasswordChangeInitial(),
          const PasswordChangeFailed(code: 'wrong-password'),
        ]),
        initialState: const PasswordChangeInitial(),
      );

      await tester.pumpWidget(buildWidget());

      await tester.enterText(
          find.byKey(const Key('oldPasswordField')), 'oldPassword');
      await tester.enterText(
          find.byKey(const Key('newPasswordField')), 'Password1234');
      await tester.enterText(
          find.byKey(const Key('confirmPasswordField')), 'Password1234');

      await tester.tap(find.text('Zapisz'));

      expect(find.text('Nieprawidłowe hasło'), findsOneWidget);
    });

    testWidgets('Shows error when new password is weak',
        (WidgetTester tester) async {
      whenListen(
        changePasswordCubit,
        Stream.fromIterable([
          const PasswordChangeInitial(),
          const PasswordChangeFailed(code: 'weak-password'),
        ]),
        initialState: const PasswordChangeInitial(),
      );

      await tester.pumpWidget(buildWidget());

      await tester.enterText(
          find.byKey(const Key('oldPasswordField')), 'oldPassword');
      await tester.enterText(
          find.byKey(const Key('newPasswordField')), 'Password1234');
      await tester.enterText(
          find.byKey(const Key('confirmPasswordField')), 'Password1234');

      await tester.tap(find.text('Zapisz'));

      expect(find.text('Hasło zbyt słabe'), findsOneWidget);
    });

    testWidgets(
        'Shows success message and pops the screen on successful password change',
        (WidgetTester tester) async {
      whenListen(
        changePasswordCubit,
        Stream.fromIterable([
          const PasswordChanged(),
        ]),
        initialState: const PasswordChangeInitial(),
      );

      await tester.pumpWidget(buildWidget());

      await tester.enterText(
          find.byKey(const Key('oldPasswordField')), 'oldPassword');
      await tester.enterText(
          find.byKey(const Key('newPasswordField')), 'newPassword');
      await tester.enterText(
          find.byKey(const Key('confirmPasswordField')), 'newPassword');

      await tester.tap(find.text('Zapisz'));
      await tester.pump();

      expect(find.text('Hasło zostało zmienione'), findsOneWidget);
      verify(() => goRouter.pop()).called(1);
    });

    testWidgets('Shows error message on failed password change',
        (WidgetTester tester) async {
      whenListen(
        changePasswordCubit,
        Stream.fromIterable([
          const PasswordChangeFailed(),
        ]),
        initialState: const PasswordChangeInitial(),
      );

      when(() => changePasswordCubit.state)
          .thenReturn(const PasswordChangeFailed());

      await tester.pumpWidget(buildWidget());

      await tester.enterText(
          find.byKey(const Key('oldPasswordField')), 'oldPassword');
      await tester.enterText(
          find.byKey(const Key('newPasswordField')), 'newPassword');
      await tester.enterText(
          find.byKey(const Key('confirmPasswordField')), 'newPassword');

      await tester.tap(find.text('Zapisz'));
      await tester.pump();

      expect(find.text('Nie udało się zmienić hasła'), findsOneWidget);
    });
  });
}
