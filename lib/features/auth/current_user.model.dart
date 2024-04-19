import 'package:equatable/equatable.dart';

import 'package:spk_app_frontend/features/auth/roles.enum.dart';

class CurrentUser extends Equatable {
  const CurrentUser({
    this.id,
    required this.uid,
    required this.token,
    this.email,
    this.phone,
    this.name,
    required this.roles,
    this.regions,
    this.teamId,
  });

  final int? id;
  final String uid;
  final String token;
  final String? email;
  final String? phone;
  final String? name;
  final List<Role> roles;
  final List<int>? regions;
  final int? teamId;

  /// Empty user which represents an unauthenticated user.
  static const empty = CurrentUser(uid: '', token: '', roles: []);

  bool get isEmpty => this == CurrentUser.empty;
  bool get isNotEmpty => this != CurrentUser.empty;

  /// Returns true if the current user is a region manager or an admin, false otherwise.
  bool get isAtLeastRegionManager =>
      checkRole([Role.regionManager, Role.admin]);

  bool checkRole(List<Role> role) =>
      roles.any((element) => role.contains(element));

  bool checkId(int? id) => id != null && this.id == id;

  @override
  List<Object?> get props => [uid, token, email, phone, name, roles, regions];
}
