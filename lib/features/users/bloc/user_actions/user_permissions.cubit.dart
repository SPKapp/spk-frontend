import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import 'package:spk_app_frontend/common/services/logger.service.dart';
import 'package:spk_app_frontend/features/auth/auth.dart';
import 'package:spk_app_frontend/features/users/repositories/interfaces.dart';

part 'user_permissions.state.dart';

/// Cubit responsible for user permissions.
///
/// Available functions:
/// - [addRoleToUser] - adds a role to a user
/// - [removeRoleFromUser] - removes a role from a user
/// - [deactivateUser] - deactivates a user
/// - [activateUser] - activates a user
///
/// Available states:
/// - [UserPermissionsInitial] - initial state
/// - [UserPermissionsSuccess] - emitted when the action is successful
/// - [UserPermissionsFailure] - emitted when the action is unsuccessful
///
class UserPermissionsCubit extends Cubit<UserPermissionsState> {
  UserPermissionsCubit(
    this._permissionsRepository,
    this.userId,
  ) : super(const UserPermissionsInitial());

  final IPermissionsRepository _permissionsRepository;
  final String userId;
  final logger = LoggerService();

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
      emit(const UserPermissionsSuccess());
    } catch (e) {
      logger.error(e);
      emit(const UserPermissionsFailure());
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
      emit(const UserPermissionsSuccess());
    } catch (e) {
      logger.error(e);
      emit(const UserPermissionsFailure());
    }
  }

  /// Deactivates a user.
  void deactivateUser() async {
    try {
      await _permissionsRepository.deactivateUser(userId);
      emit(const UserPermissionsSuccess());
    } catch (e) {
      logger.error(e);
      emit(const UserPermissionsFailure());
    }
  }

  /// Activates a user.
  void activateUser() async {
    try {
      await _permissionsRepository.activateUser(userId);
      emit(const UserPermissionsSuccess());
    } catch (e) {
      logger.error(e);
      emit(const UserPermissionsFailure());
    }
  }
}
