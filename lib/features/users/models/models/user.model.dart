import 'package:equatable/equatable.dart';

import 'package:spk_app_frontend/features/auth/auth.dart';
import 'package:spk_app_frontend/features/users/models/models/role_entity.model.dart';

final class User extends Equatable {
  const User({
    required this.id,
    required this.firstName,
    required this.lastName,
    this.email,
    this.phone,
    this.active,
    this.roles,
    this.rolesWithDetails,
  });

  final int id;
  final String firstName;
  final String lastName;
  final String? email;
  final String? phone;
  final bool? active;
  final List<Role>? roles;
  final List<RoleEntity>? rolesWithDetails;

  static User fromJson(Map<String, dynamic> json) {
    return User(
      id: int.parse(json['id']),
      firstName: json['firstname'] as String,
      lastName: json['lastname'] as String,
      email: json['email'] as String?,
      phone: json['phone'] as String?,
      active: json['active'] as bool?,
      roles: (json['roles'] as List<dynamic>?)
          ?.map((role) => Role.fromJson(role))
          .toList(),
      rolesWithDetails: (json['rolesWithDetails'] as List<dynamic>?)
          ?.map((role) => RoleEntity.fromJson(role))
          .toList(),
    );
  }

  String get fullName => '$firstName $lastName';

  @override
  List<Object?> get props =>
      [id, firstName, lastName, email, phone, active, roles, rolesWithDetails];
}
