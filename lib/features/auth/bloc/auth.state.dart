part of 'auth.cubit.dart';

sealed class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object> get props => [];
}

final class Unauthenticated extends AuthState {
  const Unauthenticated();
}

final class Authenticated extends AuthState {
  const Authenticated(this.currentUser);

  final CurrentUser currentUser;

  @override
  List<Object> get props => [currentUser];
}
