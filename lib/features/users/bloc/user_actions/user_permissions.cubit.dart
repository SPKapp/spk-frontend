import 'package:spk_app_frontend/common/bloc/interfaces/update.cubit.interface.dart';
import 'package:spk_app_frontend/features/auth/auth.dart';
import 'package:spk_app_frontend/features/users/repositories/interfaces.dart';

/// Cubit responsible for user permissions.
///
/// Available functions:
/// - [addRoleToUser] - adds a role to a user
/// - [removeRoleFromUser] - removes a role from a user
/// - [deactivateUser] - deactivates a user
/// - [activateUser] - activates a user
///
class UserPermissionsCubit extends IUpdateCubit {
  UserPermissionsCubit(
    this._permissionsRepository,
    this.userId,
  );

  final IPermissionsRepository _permissionsRepository;
  final String userId;

  /// Adds a role to a user.
  void addRoleToUser(
    Role role, {
    String? teamId,
    String? regionId,
  }) async {
    try {
      await _permissionsRepository.addRoleToUser(
        userId,
        role,
        teamId: teamId,
        regionId: regionId,
      );
      emit(const UpdateSuccess());
    } catch (e) {
      error(e, 'Failed to add role to user');
    }
  }

  /// Removes a role from a user.
  void removeRoleFromUser(
    Role role, {
    String? teamId,
    String? regionId,
  }) async {
    try {
      await _permissionsRepository.removeRoleFromUser(
        userId,
        role,
        regionId: regionId,
      );
      emit(const UpdateSuccess());
    } catch (e) {
      error(e, 'Failed to remove role from user');
    }
  }

  /// Deactivates a user.
  void deactivateUser() async {
    try {
      await _permissionsRepository.deactivateUser(userId);
      emit(const UpdateSuccess());
    } catch (e) {
      error(e, 'Failed to deactivate user');
    }
  }

  /// Activates a user.
  void activateUser() async {
    try {
      await _permissionsRepository.activateUser(userId);
      emit(const UpdateSuccess());
    } catch (e) {
      error(e, 'Failed to activate user');
    }
  }
}
