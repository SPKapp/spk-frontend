import 'package:equatable/equatable.dart';

import 'package:spk_app_frontend/features/auth/roles.enum.dart';

class CurrentUser extends Equatable {
  CurrentUser({
    int? id,
    required this.uid,
    required this.token,
    this.email,
    this.phone,
    this.name,
    required List<Role> roles,
    List<int>? managerRegions,
    List<int>? observerRegions,
    this.teamId,
  })  : _roles = roles,
        _id = id,
        managerRegions = managerRegions?.map((e) => e.toString()).toList(),
        observerRegions = observerRegions?.map((e) => e.toString()).toList();

  final int? _id;
  final String uid;
  final String token;
  final String? email;
  final String? phone;
  final String? name;
  final List<Role> _roles;
  final List<String>? managerRegions;
  final List<String>? observerRegions;
  final int? teamId;

  /// Empty user which represents an unauthenticated user.
  static final empty = CurrentUser(uid: '', token: '', roles: const []);

  bool get isEmpty => this == CurrentUser.empty;
  bool get isNotEmpty => this != CurrentUser.empty;

  /// Returns true if the current user has any of the provided roles, false otherwise.
  bool checkRole(List<Role> role) =>
      _roles.any((element) => role.contains(element));

  /// Returns true if provided id is equal to the current user id, false otherwise.
  bool checkId(int? id) => id != null && _id == id;

  /// Returns true if provided teamId is equal to the current user teamId, false otherwise.
  ///
  /// If the teamId is null, the function will return false.
  bool checkTeamId(int? teamId) => teamId != null && this.teamId == teamId;

  @override
  List<Object?> get props => [
        _id,
        uid,
        token,
        email,
        phone,
        name,
        _roles,
        managerRegions,
        observerRegions,
        teamId
      ];

  String get debugString =>
      '\nid: $_id \nuid: $uid, \nemail: $email, \nphone: $phone, \nname: $name, \nroles: $_roles, \nregions: $managerRegions, \nteamId: $teamId';
}
