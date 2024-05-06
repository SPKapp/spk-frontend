import 'package:spk_app_frontend/features/auth/auth.dart';

abstract interface class IPermissionsRepository {
  /// Adds a role to a user.
  Future<void> addRoleToUser(
    String userId,
    Role role, {
    String? teamId,
    String? regionId,
  });

  /// Removes a role from a user.
  Future<void> removeRoleFromUser(
    String userId,
    Role role, {
    String? regionId,
  });
}
