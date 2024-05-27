import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:mocktail/mocktail.dart';

import 'package:spk_app_frontend/features/notifications/bloc/notifications.cubit.dart';

class MockStorage extends Mock implements Storage {}

void main() {
  group(FcmTokenCubit, () {
    late FcmTokenCubit fcmTokenCubit;
    late Storage storage;

    const token = 'test_token';

    setUp(() {
      storage = MockStorage();

      when(
        () => storage.write(any(), any<dynamic>()),
      ).thenAnswer((_) async {});
      HydratedBloc.storage = storage;

      fcmTokenCubit = FcmTokenCubit();
    });

    tearDown(() {
      fcmTokenCubit.close();
    });

    test('initial state is NotificationsNotConfigured', () {
      expect(fcmTokenCubit.state, isA<NotificationsNotConfigured>());
    });

    blocTest<FcmTokenCubit, NotificationsState>(
      'emits [NotificationsAllowed] when setToken is called',
      build: () => fcmTokenCubit,
      act: (cubit) => cubit.setToken(token),
      expect: () => [
        const NotificationsAllowed(token),
      ],
    );

    blocTest<FcmTokenCubit, NotificationsState>(
      'emits [NotificationsNotConfigured] when setNotConfigured is called',
      build: () => fcmTokenCubit,
      act: (cubit) => cubit.setNotConfigured(),
      expect: () => [
        const NotificationsNotConfigured(),
      ],
    );

    blocTest<FcmTokenCubit, NotificationsState>(
      'emits [NotificationsNotAllowed] when setNotAllowed is called',
      build: () => fcmTokenCubit,
      act: (cubit) => cubit.setNotAllowed(),
      expect: () => [
        const NotificationsNotAllowed(),
      ],
    );
  });
}
