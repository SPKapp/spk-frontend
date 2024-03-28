import 'package:equatable/equatable.dart';

import 'package:spk_app_frontend/features/users/models/models/user.model.dart';

final class Team extends Equatable {
  const Team({
    required this.id,
    required this.users,
  });

  final int id;
  final List<User> users;

  static Team fromJson(Map<String, dynamic> json) {
    // TODO: Add tests
    return Team(
      id: int.parse(json['id']),
      users: (json['users'] as List)
          .map((user) => User.fromJson(user as Map<String, dynamic>))
          .toList(),
    );
  }

  @override
  List<Object?> get props => [id, users];
}
