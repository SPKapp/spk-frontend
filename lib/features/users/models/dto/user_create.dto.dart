class UserCreateDto {
  UserCreateDto({
    required this.firstname,
    required this.lastname,
    required this.email,
    required this.phone,
    this.teamId,
    this.regionId,
  });

  final String firstname;
  final String lastname;
  final String email;
  final String phone;

  // TODO: Add Address fields

  final String? teamId;
  final String? regionId;

  Map<String, dynamic> toJson() {
    return {
      'firstname': firstname,
      'lastname': lastname,
      'email': email,
      'phone': phone,
      if (teamId != null) 'teamId': teamId,
      if (regionId != null) 'regionId': regionId,
    };
  }
}
