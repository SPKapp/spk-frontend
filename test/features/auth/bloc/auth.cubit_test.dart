import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:spk_app_frontend/features/auth/auth.service.dart';
import 'package:spk_app_frontend/features/auth/bloc/auth.cubit.dart';
import 'package:spk_app_frontend/features/auth/current_user.model.dart';

class MockAuthService extends Mock implements AuthService {}

void main() {
  group(AuthCubit, () {
    late AuthCubit authCubit;
    late MockAuthService mockAuthService;
    late StreamController<CurrentUser> userStream;

    setUp(() {
      mockAuthService = MockAuthService();
      userStream = StreamController<CurrentUser>();
      when(() => mockAuthService.user).thenAnswer((_) => userStream.stream);

      authCubit = AuthCubit(authService: mockAuthService);
    });

    tearDown(() {
      authCubit.close();
    });

    test('initial state is Unauthenticated', () {
      expect(authCubit.state, isA<Unauthenticated>());
    });

    blocTest<AuthCubit, AuthState>(
      'emits [Authenticated] when user changes',
      build: () => authCubit,
      act: (cubit) => userStream.add(
        const CurrentUser(uid: '123', token: '123', roles: []),
      ),
      seed: () => const Unauthenticated(),
      expect: () => [
        const Authenticated(
          CurrentUser(uid: '123', token: '123', roles: []),
        ),
      ],
      verify: (bloc) {
        expect(
          authCubit.currentUser,
          const CurrentUser(uid: '123', token: '123', roles: []),
        );
      },
    );

    blocTest<AuthCubit, AuthState>(
      'emits [Unauthenticated] when user changes',
      build: () => authCubit,
      act: (cubit) => userStream.add(CurrentUser.empty),
      seed: () => const Authenticated(
        CurrentUser(uid: '123', token: '123', roles: []),
      ),
      expect: () => [
        const Unauthenticated(),
      ],
      verify: (bloc) {
        expect(authCubit.currentUser, CurrentUser.empty);
      },
    );

    blocTest<AuthCubit, AuthState>(
      'emits [Unauthenticated] when logout is called',
      setUp: () {
        when(() => mockAuthService.logout()).thenAnswer((_) async {
          userStream.add(CurrentUser.empty);
        });
      },
      build: () => authCubit,
      act: (cubit) => cubit.logout(),
      seed: () => const Authenticated(
        CurrentUser(uid: '123', token: '123', roles: []),
      ),
      expect: () => [
        const Unauthenticated(),
      ],
    );
  });
}
