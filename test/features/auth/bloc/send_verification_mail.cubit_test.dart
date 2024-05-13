import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:spk_app_frontend/features/auth/auth.service.dart';
import 'package:spk_app_frontend/features/auth/bloc/send_verification_mail.cubit.dart';

class MockAuthService extends Mock implements AuthService {}

void main() {
  group(SendVerificationMailCubit, () {
    late SendVerificationMailCubit sendVerificationMailCubit;
    late AuthService authService;

    setUp(() {
      authService = MockAuthService();
      sendVerificationMailCubit =
          SendVerificationMailCubit(authService: authService);
    });

    tearDown(() {
      sendVerificationMailCubit.close();
    });

    test('initial state is SendVerificationMailInitial', () {
      expect(sendVerificationMailCubit.state,
          equals(const SendVerificationMailInitial()));
    });

    blocTest(
      'emits [SendVerificationMailSuccess] when sendVerificationMail is called',
      setUp: () {
        when(() => authService.sendVerificationMail()).thenAnswer((_) async {});
      },
      build: () => sendVerificationMailCubit,
      act: (cubit) => cubit.sendVerificationMail(),
      expect: () => [const SendVerificationMailSuccess()],
      verify: (_) {
        verify(() => authService.sendVerificationMail()).called(1);
      },
    );

    blocTest(
      'emits [SendVerificationMailFailure] when sendVerificationMail throws',
      setUp: () {
        when(() => authService.sendVerificationMail()).thenThrow(Exception());
      },
      build: () => sendVerificationMailCubit,
      act: (cubit) => cubit.sendVerificationMail(),
      expect: () => [const SendVerificationMailFailure()],
      verify: (_) {
        verify(() => authService.sendVerificationMail()).called(1);
      },
    );
  });
}
