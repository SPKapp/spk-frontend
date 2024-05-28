import 'package:bloc_test/bloc_test.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:spk_app_frontend/features/notifications/notifications.dart';
import 'package:spk_app_frontend/features/notifications/repositories/interfaces.dart';

class MockFcmTokenCubit extends MockCubit<NotificationsState>
    implements FcmTokenCubit {}

class MockFcmTokensRepository extends Mock implements IFcmTokensRepository {}

class MockFirebaseMessaging extends Mock implements FirebaseMessaging {}

class MockNotificationSettings extends Mock implements NotificationSettings {}

void main() {
  group(NotificationService, () {
    late NotificationService notificationService;
    late FcmTokenCubit fcmTokenCubit;
    late IFcmTokensRepository fcmTokensRepository;
    late FirebaseMessaging firebaseMessaging;
    late NotificationSettings notificationSettings;

    String token = 'test_token';

    setUp(() {
      fcmTokenCubit = MockFcmTokenCubit();
      fcmTokensRepository = MockFcmTokensRepository();
      firebaseMessaging = MockFirebaseMessaging();
      notificationSettings = MockNotificationSettings();

      when(
        () => firebaseMessaging.requestPermission(
          alert: true,
          announcement: false,
          badge: true,
          carPlay: false,
          criticalAlert: false,
          provisional: false,
          sound: true,
        ),
      ).thenAnswer((_) async => notificationSettings);
      when(() => fcmTokenCubit.setToken(any())).thenAnswer((_) {});
      when(() => fcmTokenCubit.setNotAllowed()).thenAnswer((_) {});
      when(() => fcmTokensRepository.update(any())).thenAnswer((_) async {});
      when(() => fcmTokensRepository.delete(any())).thenAnswer((_) async {});
      when(() => firebaseMessaging.deleteToken()).thenAnswer((_) async {});
      when(() => firebaseMessaging.getInitialMessage())
          .thenAnswer((_) async => null);

      notificationService = NotificationService(
        fcmTokenCubit: fcmTokenCubit,
        fcmTokensRepository: fcmTokensRepository,
        fcm: firebaseMessaging,
      );
    });

    group('register', () {
      test(
          'register() should request permission and update token if authorized',
          () async {
        when(() => notificationSettings.authorizationStatus)
            .thenReturn(AuthorizationStatus.authorized);
        when(() => firebaseMessaging.getToken(vapidKey: any(named: 'vapidKey')))
            .thenAnswer((_) async => token);

        await expectLater(notificationService.register(), completes);

        verify(() => fcmTokenCubit.setToken(token)).called(1);
        verify(() => fcmTokensRepository.update(token)).called(1);
      });

      test('register() should set not allowed if permission denied', () async {
        when(() => notificationSettings.authorizationStatus)
            .thenReturn(AuthorizationStatus.denied);

        await expectLater(
            () => notificationService.register(), returnsNormally);

        verify(() => fcmTokenCubit.setNotAllowed()).called(1);
      });

      test('register() should set not configured if permission not determined',
          () async {
        when(() => notificationSettings.authorizationStatus)
            .thenReturn(AuthorizationStatus.notDetermined);

        await expectLater(
            () => notificationService.register(), returnsNormally);

        verify(() => fcmTokenCubit.setNotConfigured()).called(1);
      });

      test('register() should handle error when getting FCM token', () async {
        when(() => notificationSettings.authorizationStatus)
            .thenReturn(AuthorizationStatus.authorized);
        when(() => firebaseMessaging.getToken(vapidKey: any(named: 'vapidKey')))
            .thenThrow(Exception('Test error'));

        await expectLater(notificationService.register(), completes);

        verifyNever(() => fcmTokenCubit.setToken(token));
        verifyNever(() => fcmTokensRepository.update(token));
      });
    });

    group('deregister', () {
      test('deregister() should delete token if allowed', () async {
        when(() => fcmTokenCubit.state).thenReturn(NotificationsAllowed(token));

        await expectLater(notificationService.deregister(), completes);

        verify(() => fcmTokenCubit.setNotConfigured()).called(1);
        verify(() => fcmTokensRepository.delete(token)).called(1);
        verify(() => firebaseMessaging.deleteToken()).called(1);
      });

      test('deregister() should handle warning when token not determined',
          () async {
        when(() => fcmTokenCubit.state)
            .thenReturn(const NotificationsNotConfigured());

        await expectLater(notificationService.deregister(), completes);

        verifyNever(() => fcmTokenCubit.setNotConfigured());
        verifyNever(() => fcmTokensRepository.delete(token));
        verifyNever(() => firebaseMessaging.deleteToken());
      });

      test('deregister() should handle warning when notifications not allowed',
          () async {
        when(() => fcmTokenCubit.state)
            .thenReturn(const NotificationsNotAllowed());

        await expectLater(notificationService.deregister(), completes);

        verifyNever(() => fcmTokenCubit.setNotConfigured());
        verifyNever(() => fcmTokensRepository.delete(token));
        verifyNever(() => firebaseMessaging.deleteToken());
      });
    });
  });
}
