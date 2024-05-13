import 'package:equatable/equatable.dart';

import 'package:spk_app_frontend/features/users/models/models/user.model.dart';

final class Team extends Equatable {
  const Team({
    required this.id,
    required this.users,
  });

  final String id;
  final List<User> users;

  static Team fromJson(Map<String, dynamic> json) {
    return Team(
      id: json['id'] as String,
      users: (json['users'] as List)
          .map((user) => User.fromJson(user as Map<String, dynamic>))
          .toList(),
    );
  }

  String get name => users.map((user) => user.fullName).join(', ');

  @override
  List<Object?> get props => [id, users];
}
