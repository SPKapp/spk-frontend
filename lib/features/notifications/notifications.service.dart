import 'dart:async';
import 'package:firebase_messaging/firebase_messaging.dart';
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
            _logger.debug('FCM token: $token');
            _fcmTokenCubit.setToken(token);

            await _fcmTokensRepository.update(token);
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

    _logger.debug(
      'Got a message whilst in the foreground!,  ${message.category}\nMessage data: ${message.data}\nMessage type: ${message.messageType}',
    );

    if (message.notification != null) {
      _logger.debug(
        'Message also contained a notification: ${message.notification?.body} ${message.notification}',
      );
    }
  }

  void _onOpenAppHandler(RemoteMessage message) {
    if (message.data['category'] == 'groupAssigned') {
      AppRouter.router.go('/rabbitGroup/${message.data['groupId']}');
    } else if (message.data['category'] == 'rabbitAssigned') {
      AppRouter.router.go('/rabbit/${message.data['rabbitId']}');
    } else if (message.data['category'] == 'rabbitMoved') {
      AppRouter.router.go('/rabbit/${message.data['rabbitId']}');
    } else if (message.data['category'] == 'admissionToConfirm') {
      AppRouter.router.go(
        '/rabbit/${message.data['rabbitId']}',
        extra: {'launchSetStatusAction': true},
      );
    } else if (message.data['category'] == 'adoptionToConfirm') {
      AppRouter.router.go(
        '/rabbitGroup/${message.data['groupId']}',
        extra: {'launchSetAdoptedAction': true},
      );
    } else if (message.data['category'] == 'nearVetVisit') {
      AppRouter.router.go('/rabbit/${message.data['rabbitId']}');
      AppRouter.router.push('/note/${message.data['noteId']}', extra: {
        'rabbitName': message.data['rabbitName'],
      });
    } else if (message.data['category'] == 'vetVisitEnd') {
      AppRouter.router.go('/rabbit/${message.data['rabbitId']}');
      AppRouter.router.push('/note/${message.data['noteId']}', extra: {
        'rabbitName': message.data['rabbitName'],
      });
    } else {
      AppRouter.router.go('/');
    }
  }
}
