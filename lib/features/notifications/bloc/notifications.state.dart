part of 'notifications.cubit.dart';

sealed class NotificationsState extends Equatable {
  const NotificationsState();

  @override
  List<Object> get props => [];
}

final class NotificationsNotConfigured extends NotificationsState {
  const NotificationsNotConfigured();
}

final class NotificationsNotAllowed extends NotificationsState {
  const NotificationsNotAllowed();
}

final class NotificationsAllowed extends NotificationsState {
  const NotificationsAllowed(this.token);

  final String token;

  @override
  List<Object> get props => [token];
}
