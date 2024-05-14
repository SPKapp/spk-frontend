part of 'user_update.cubit.dart';

sealed class UserUpdateState extends Equatable {
  const UserUpdateState();

  @override
  List<Object> get props => [];
}

final class UserUpdateInitial extends UserUpdateState {
  const UserUpdateInitial();
}

final class UserUpdated extends UserUpdateState {
  const UserUpdated();
}

final class UserUpdateFailure extends UserUpdateState {
  const UserUpdateFailure({this.code = 'unknown'});
  final String code;

  @override
  List<Object> get props => [code];
}
