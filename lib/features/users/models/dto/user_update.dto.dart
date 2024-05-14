import 'package:equatable/equatable.dart';

final class UserUpdateDto extends Equatable {
  const UserUpdateDto({
    this.id,
    this.firstName,
    this.lastName,
    this.email,
    this.phone,
  });

  final String? id;
  final String? firstName;
  final String? lastName;
  final String? email;
  final String? phone;

  bool get hasChanges =>
      firstName != null || lastName != null || email != null || phone != null;

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      if (firstName != null) 'firstname': firstName,
      if (lastName != null) 'lastname': lastName,
      if (email != null) 'email': email,
      if (phone != null) 'phone': phone,
    };
  }

  @override
  List<Object?> get props => [id, firstName, lastName, email, phone];
}
