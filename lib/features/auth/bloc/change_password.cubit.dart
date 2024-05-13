import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:spk_app_frontend/common/services/logger.service.dart';
import 'package:spk_app_frontend/features/auth/auth.service.dart';

part 'change_password.state.dart';

/// Cubit for changing user password
///
/// Available functions:
/// - [changePassword] - changes user password
///
/// Available states:
/// - [PasswordChangeInitial] - initial state
/// - [PasswordChanged] - password changed successfully
/// - [PasswordChangeFailed] - password change failed
///
class ChangePasswordCubit extends Cubit<PasswordChangeState> {
  ChangePasswordCubit({
    AuthService? authService,
  })  : _authService = authService ?? AuthService(),
        super(const PasswordChangeInitial());

  final AuthService _authService;
  final _logger = LoggerService();

  void changePassword(String oldPassword, String newPassword) async {
    emit(const PasswordChangeInitial());
    try {
      await _authService.changePassword(oldPassword, newPassword);
      emit(const PasswordChanged());
    } on ChangePasswordException catch (e) {
      _logger.error('Error when Changing Password', error: e);

      emit(PasswordChangeFailed(
        code: e.code,
      ));
    } catch (e) {
      _logger.error('Error when Changing Password', error: e);

      emit(const PasswordChangeFailed());
    }
  }
}
