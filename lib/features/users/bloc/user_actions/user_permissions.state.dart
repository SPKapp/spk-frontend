part of 'user_permissions.cubit.dart';

sealed class UserPermissionsState extends Equatable {
  const UserPermissionsState();

  @override
  List<Object> get props => [];
}

final class UserPermissionsInitial extends UserPermissionsState {
  const UserPermissionsInitial();
}

final class UserPermissionsSuccess extends UserPermissionsState {
  const UserPermissionsSuccess();
}

final class UserPermissionsFailure extends UserPermissionsState {
  const UserPermissionsFailure();
}
