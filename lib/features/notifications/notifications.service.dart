import 'dart:async';
import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:spk_app_frontend/app/router.dart';
import 'package:spk_app_frontend/common/services/logger.service.dart';

import 'package:spk_app_frontend/config/config.dart';
import 'package:spk_app_frontend/features/notifications/bloc/notifications.cubit.dart';
import 'package:spk_app_frontend/features/notifications/repositories/interfaces.dart';

enum NotificationsStatus {
  denied,
  authorized,
}

class NotificationService {
  NotificationService({
    required FcmTokenCubit fcmTokenCubit,
    required IFcmTokensRepository fcmTokensRepository,
    FirebaseMessaging? fcm,
  })  : _fcmTokenCubit = fcmTokenCubit,
        _fcmTokensRepository = fcmTokensRepository,
        _fcm = fcm ?? FirebaseMessaging.instance {
    _init();
  }

  final FirebaseMessaging _fcm;
  final FcmTokenCubit _fcmTokenCubit;
  final IFcmTokensRepository _fcmTokensRepository;
  final _logger = LoggerService();

  Future<void> _init() async {
    if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
      FirebaseMessaging.onBackgroundMessage(_onBackgroundMessageHandler);
    }

    FirebaseMessaging.onMessage.listen(_onFrontendMessageHandler);
    FirebaseMessaging.onMessageOpenedApp.listen(_onOpenAppHandler);

    RemoteMessage? initialMessage = await _fcm.getInitialMessage();
    if (initialMessage != null) {
      _onOpenAppHandler(initialMessage);
    }
  }

  Future<void> register() async {
    try {
      NotificationSettings settings = await _fcm.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );

      switch (settings.authorizationStatus) {
        case AuthorizationStatus.authorized:
        case AuthorizationStatus.provisional:
          final token = await _fcm.getToken(vapidKey: AppConfig.webVapidKey);

          if (token == null) {
            _logger.error('Failed to get new FCM token');
            await deregister();
          } else {
            _fcmTokenCubit.setToken(token);

            await _fcmTokensRepository.update(token);
            _logger.debug('FCM token: $token');
          }
          break;
        case AuthorizationStatus.denied:
          _logger.info('Notifications permission denied');
          _fcmTokenCubit.setNotAllowed();
          break;
        case AuthorizationStatus.notDetermined:
          _logger.info('Notifications permission not determined');
          _fcmTokenCubit.setNotConfigured();
          break;
      }
    } catch (e) {
      _logger.error('Failed to get FCM token', error: e);
    }
  }

  Future<void> deregister() async {
    _logger.debug('Removing FCM token: ${_fcmTokenCubit.state}');

    switch (_fcmTokenCubit.state) {
      case NotificationsAllowed state:
        await _fcmTokensRepository.delete(state.token);
        _fcmTokenCubit.setNotConfigured();
        await _fcm.deleteToken();
        break;
      case NotificationsNotConfigured():
        _logger.warning('Trying to remove not set FCM token');
        break;
      case NotificationsNotAllowed():
        _logger.warning('Notifications not allowed');
        break;
    }
  }

  void _onFrontendMessageHandler(RemoteMessage message) {
    // TODO: Implement this

    print('Got a message whilst in the foreground!,  ${message.category}');
    print('Message data: ${message.data}');
    print('Message type: ${message.messageType}');

    if (message.notification != null) {
      print(
          'Message also contained a notification: ${message.notification?.body} ${message.notification}');
    }
  }

  void _onOpenAppHandler(RemoteMessage message) {
    print('Handling a message from the background or terminated state!');

    if (message.data['category'] == 'groupAssigned') {
      AppRouter.router.go('/rabbitGroup/${message.data['groupId']}');
    } else if (message.data['category'] == 'rabbitAssigned') {
      AppRouter.router.go('/rabbit/${message.data['rabbitId']}');
    } else if (message.data['category'] == 'rabbitMoved') {
      AppRouter.router.go('/rabbit/${message.data['rabbitId']}');
    } else if (message.data['category'] == 'rabbitPickup') {
      // TODO
    } else if (message.data['category'] == 'adoptionToConfirm') {
      AppRouter.router.go(
        '/rabbitGroup/${message.data['groupId']}',
        extra: {'launchSetAdoptedAction': true},
      );
    } else if (message.data['category'] == 'nearVetVisit') {
      // TODO
    } else if (message.data['category'] == 'vetVisitEnd') {
      // TODO
    } else {
      AppRouter.router.go('/');
    }
  }
}

@pragma('vm:entry-point')
Future<void> _onBackgroundMessageHandler(RemoteMessage message) async {
  // TODO: Implement this

  // If you're going to use other Firebase services in the background, such as Firestore,
  // make sure you call `initializeApp` before using other Firebase services.
  // await Firebase.initializeApp();

  print('Handling a background message: ${message.messageId}');
  print('Message data: ${message.data}');

  if (message.notification != null) {
    print(
        'Message also contained a notification: ${message.notification?.body}');
  }
}