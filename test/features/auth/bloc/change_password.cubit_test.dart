import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:spk_app_frontend/features/auth/auth.service.dart';
import 'package:spk_app_frontend/features/auth/bloc/change_password.cubit.dart';

class MockAuthService extends Mock implements AuthService {}

void main() {
  group(ChangePasswordCubit, () {
    late ChangePasswordCubit changePasswordCubit;
    late AuthService authService;

    setUp(() {
      authService = MockAuthService();
      changePasswordCubit = ChangePasswordCubit(authService: authService);
    });

    tearDown(() {
      changePasswordCubit.close();
    });

    test('initial state is ChangePasswordInitial', () {
      expect(changePasswordCubit.state, equals(const PasswordChangeInitial()));
    });

    group('changePassword', () {
      const oldPassword = 'old_password';
      const newPassword = 'new_password';

      blocTest<ChangePasswordCubit, PasswordChangeState>(
        'emits [ChangePasswordInitial, PasswordChanged] when successful',
        setUp: () {
          when(() => authService.changePassword(any(), any()))
              .thenAnswer((_) => Future.value());
        },
        build: () => changePasswordCubit,
        act: (cubit) => cubit.changePassword(oldPassword, newPassword),
        expect: () => const <PasswordChangeState>[
          PasswordChangeInitial(),
          PasswordChanged(),
        ],
        verify: (_) {
          verify(() => authService.changePassword(oldPassword, newPassword))
              .called(1);
        },
      );

      blocTest<ChangePasswordCubit, PasswordChangeState>(
        'emits [ChangePasswordInitial, PasswordChangeFailed] when wrong password',
        setUp: () {
          when(() => authService.changePassword(any(), any()))
              .thenThrow(ChangePasswordException('wrong-password'));
        },
        build: () => changePasswordCubit,
        act: (cubit) => cubit.changePassword(oldPassword, newPassword),
        expect: () => const <PasswordChangeState>[
          PasswordChangeInitial(),
          PasswordChangeFailed(code: 'wrong-password'),
        ],
        verify: (_) {
          verify(() => authService.changePassword(oldPassword, newPassword))
              .called(1);
        },
      );

      blocTest<ChangePasswordCubit, PasswordChangeState>(
        'emits [ChangePasswordInitial, PasswordChangeFailed] when weak password',
        setUp: () {
          when(() => authService.changePassword(any(), any()))
              .thenThrow(ChangePasswordException('weak-password'));
        },
        build: () => changePasswordCubit,
        act: (cubit) => cubit.changePassword(oldPassword, newPassword),
        expect: () => const <PasswordChangeState>[
          PasswordChangeInitial(),
          PasswordChangeFailed(code: 'weak-password'),
        ],
        verify: (_) {
          verify(() => authService.changePassword(oldPassword, newPassword))
              .called(1);
        },
      );

      blocTest<ChangePasswordCubit, PasswordChangeState>(
        'emits [ChangePasswordInitial, PasswordChangeFailed] when unknown error',
        setUp: () {
          when(() => authService.changePassword(any(), any()))
              .thenThrow(Exception());
        },
        build: () => changePasswordCubit,
        act: (cubit) => cubit.changePassword(oldPassword, newPassword),
        expect: () => const <PasswordChangeState>[
          PasswordChangeInitial(),
          PasswordChangeFailed(),
        ],
        verify: (_) {
          verify(() => authService.changePassword(oldPassword, newPassword))
              .called(1);
        },
      );
    });
  });
}
