import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:spk_app_frontend/features/auth/auth.service.dart';
import 'package:spk_app_frontend/features/auth/bloc/auth.cubit.dart';
import 'package:spk_app_frontend/features/auth/current_user.model.dart';
import 'package:spk_app_frontend/features/notifications/notifications.dart';

class MockAuthService extends Mock implements AuthService {}

class MockNotificationService extends Mock implements NotificationService {}

void main() {
  group(AuthCubit, () {
    late AuthCubit authCubit;
    late MockAuthService mockAuthService;
    late MockNotificationService mockNotificationService;
    late StreamController<CurrentUser> userStream;

    setUp(() {
      mockAuthService = MockAuthService();
      mockNotificationService = MockNotificationService();
      userStream = StreamController<CurrentUser>();
      when(() => mockAuthService.user).thenAnswer((_) => userStream.stream);

      authCubit = AuthCubit(
        authService: mockAuthService,
        notificationService: mockNotificationService,
      );
    });

    tearDown(() {
      authCubit.close();
    });

    test('initial state is Unauthenticated', () {
      expect(authCubit.state, isA<Unauthenticated>());
    });

    blocTest<AuthCubit, AuthState>(
      'emits [Authenticated] when user changes',
      setUp: () {
        when(() => mockNotificationService.register()).thenAnswer((_) async {});
      },
      build: () => authCubit,
      act: (cubit) => userStream.add(
        CurrentUser(uid: '123', token: '123', roles: const []),
      ),
      seed: () => const Unauthenticated(),
      expect: () => [
        Authenticated(
          CurrentUser(uid: '123', token: '123', roles: const []),
        ),
      ],
      verify: (bloc) {
        expect(
          authCubit.currentUser,
          CurrentUser(uid: '123', token: '123', roles: const []),
        );
        verify(() => mockNotificationService.register()).called(1);
      },
    );

    blocTest<AuthCubit, AuthState>(
      'emits [Unauthenticated] when user changes',
      build: () => authCubit,
      act: (cubit) => userStream.add(CurrentUser.empty),
      seed: () => Authenticated(
        CurrentUser(uid: '123', token: '123', roles: const []),
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
        when(() => mockNotificationService.deregister())
            .thenAnswer((_) async {});
      },
      build: () => authCubit,
      act: (cubit) => cubit.logout(),
      seed: () => Authenticated(
        CurrentUser(uid: '123', token: '123', roles: const []),
      ),
      expect: () => [
        const Unauthenticated(),
      ],
      verify: (bloc) {
        verify(() => mockNotificationService.deregister()).called(1);
        verify(() => mockAuthService.logout()).called(1);
      },
    );
  });
}
