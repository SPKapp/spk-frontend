import 'package:equatable/equatable.dart';

final class User extends Equatable {
  const User({
    required this.id,
    required this.firstName,
    required this.lastName,
    this.email,
    this.phone,
  });

  final int id;
  final String firstName;
  final String lastName;
  final String? email;
  final String? phone;

  static User fromJson(Map<String, dynamic> json) {
    // TODO: Add tests
    return User(
      id: int.parse(json['id']),
      firstName: json['firstname'] as String,
      lastName: json['lastname'] as String,
      email: json['email'] as String?,
      phone: json['phone'] as String?,
    );
  }

  @override
  List<Object?> get props => [id, firstName, lastName, email, phone];
}
