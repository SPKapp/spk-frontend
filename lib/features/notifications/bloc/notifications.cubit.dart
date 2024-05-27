import 'package:equatable/equatable.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';

part 'notifications.state.dart';

/// A cubit that manages the availability of notifications.
///
/// Available states:
/// - NotificationsNotDetermined - the user has not decided yet
/// - NotificationsNotAllowed - the user has decided to not allow notifications
/// - NotificationsAllowed - the user has allowed notifications
///
abstract class NotificationsCubit extends HydratedCubit<NotificationsState> {
  NotificationsCubit(super.initialState);
}

/// A implementation of [NotificationsCubit] that manages the availability of FCM tokens.
/// With methods to set, delete and set as not allowed the token.
///
/// Available functions:
/// - setToken(String token) - sets the token
/// - setNotConfigured() - deletes the token
/// - setNotAllowed() - tells that notifications are not allowed
///
class FcmTokenCubit extends NotificationsCubit {
  FcmTokenCubit() : super(const NotificationsNotConfigured());

  void setToken(String token) => emit(NotificationsAllowed(token));

  void setNotConfigured() => emit(const NotificationsNotConfigured());

  void setNotAllowed() => emit(const NotificationsNotAllowed());

  @override
  NotificationsState? fromJson(Map<String, dynamic> json) {
    final value = json['value'] as String?;
    if (value == null) return const NotificationsNotConfigured();
    return NotificationsAllowed(value);
  }

  @override
  Map<String, String?> toJson(NotificationsState? state) {
    switch (state) {
      case NotificationsAllowed():
        return {'value': state.token};
      default:
        return {'value': null};
    }
  }
}
