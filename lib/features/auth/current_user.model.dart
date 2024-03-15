import 'package:equatable/equatable.dart';

// TODO: add roles enum

class CurrentUser extends Equatable {
  /// {@macro user}
  const CurrentUser({
    required this.uid,
    this.email,
    this.phone,
    this.name,
    this.roles,
  });

  final String uid;
  final String? email;
  final String? phone;
  final String? name;
  final List<String>? roles;

  /// Empty user which represents an unauthenticated user.
  static const empty = CurrentUser(uid: '');

  bool get isEmpty => this == CurrentUser.empty;
  bool get isNotEmpty => this != CurrentUser.empty;

  @override
  List<Object?> get props => [uid, email, phone, name, roles];
}
