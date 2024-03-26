part of 'user_create.cubit.dart';

sealed class UserCreateState extends Equatable {
  const UserCreateState();

  @override
  List<Object> get props => [];
}

final class UserCreateInitial extends UserCreateState {
  const UserCreateInitial();
}

final class UserCreated extends UserCreateState {
  const UserCreated({
    required this.userId,
  });

  final int userId;

  @override
  List<Object> get props => [userId];
}

final class UserCreateFailure extends UserCreateState {
  const UserCreateFailure();
}
