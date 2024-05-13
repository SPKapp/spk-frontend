part of 'change_password.cubit.dart';

sealed class PasswordChangeState extends Equatable {
  const PasswordChangeState();

  @override
  List<Object> get props => [];
}

final class PasswordChangeInitial extends PasswordChangeState {
  const PasswordChangeInitial();
}

final class PasswordChanged extends PasswordChangeState {
  const PasswordChanged();
}

/// A state that represents a failed password change.
///
/// [code] types:
/// - 'unknown' - unknown error
/// - 'wrong-password' - wrong old password
/// - 'weak-password' - weak new password
///
final class PasswordChangeFailed extends PasswordChangeState {
  const PasswordChangeFailed({
    this.code = 'unknown',
  });

  final String code;

  @override
  List<Object> get props => [code];
}
