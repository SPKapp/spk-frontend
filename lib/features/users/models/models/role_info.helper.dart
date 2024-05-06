import 'package:spk_app_frontend/features/auth/auth.dart';
import 'package:spk_app_frontend/features/users/models/models/role_entity.model.dart';

final class RoleInfo {
  RoleInfo(List<RoleEntity>? roles)
      : hasAnyRole = roles?.isNotEmpty ?? false,
        isAdmin = roles?.any((role) => role.role == Role.admin) ?? false,
        isVolunteer =
            roles?.any((role) => role.role == Role.volunteer) ?? false,
        managerRegions = roles
                ?.where((role) => role.role == Role.regionManager)
                .map((role) => role.additionalInfo!)
                .toList() ??
            [],
        observerRegions = roles
                ?.where((role) => role.role == Role.regionRabbitObserver)
                .map((role) => role.additionalInfo!)
                .toList() ??
            [];

  final bool hasAnyRole;
  final bool isAdmin;
  final bool isVolunteer;
  final List<String> managerRegions;
  final List<String> observerRegions;
}
