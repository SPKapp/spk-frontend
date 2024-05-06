part of 'user.cubit.dart';

sealed class UserState extends Equatable {
  const UserState();

  @override
  List<Object?> get props => [];
}

final class UserInitial extends UserState {
  const UserInitial();
}

final class UserSuccess extends UserState {
  const UserSuccess({
    required this.user,
  });

  final User user;

  @override
  List<Object?> get props => [user];
}

final class UserFailure extends UserState {
  const UserFailure();
}
