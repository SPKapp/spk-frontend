import 'package:equatable/equatable.dart';

import 'package:spk_app_frontend/features/auth/auth.dart';

final class RoleEntity extends Equatable {
  const RoleEntity({
    required this.role,
    this.additionalInfo,
  });

  final Role role;
  final String? additionalInfo;

  factory RoleEntity.fromJson(Map<String, dynamic> json) {
    return RoleEntity(
      role: Role.fromJson(json['role']),
      additionalInfo: json['additionalInfo'] as String?,
    );
  }

  @override
  List<Object?> get props => [role, additionalInfo];
}
