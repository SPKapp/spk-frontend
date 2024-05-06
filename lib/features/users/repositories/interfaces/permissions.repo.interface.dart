import 'package:spk_app_frontend/features/auth/auth.dart';

abstract interface class IPermissionsRepository {
  Future<void> addRoleToUser(
    String userId,
    Role role, {
    String? teamId,
    String? regionId,
  });
}
