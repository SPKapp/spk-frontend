import 'package:equatable/equatable.dart';

import 'package:spk_app_frontend/features/auth/roles.enum.dart';

class CurrentUser extends Equatable {
  const CurrentUser({
    required this.uid,
    required this.token,
    this.email,
    this.phone,
    this.name,
    this.roles,
  });

  final String uid;
  final String token;
  final String? email;
  final String? phone;
  final String? name;
  final List<Role>? roles;

  /// Empty user which represents an unauthenticated user.
  static const empty = CurrentUser(uid: '', token: '');

  bool get isEmpty => this == CurrentUser.empty;
  bool get isNotEmpty => this != CurrentUser.empty;

  @override
  List<Object?> get props => [uid, token, email, phone, name, roles];
}
