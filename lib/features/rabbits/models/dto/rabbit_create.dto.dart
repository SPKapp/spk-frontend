import 'package:spk_app_frontend/features/rabbits/models/models.dart';

// TODO: Add Status
class RabbitCreateDto {
  RabbitCreateDto({
    required this.name,
    this.color,
    this.breed,
    this.gender = Gender.unknown,
    this.birthDate,
    this.confirmedBirthDate = false,
    this.admissionDate,
    this.admissionType,
    this.fillingDate,
    this.rabbitGroupId,
    this.regionId,
  });

  final String name;
  final String? color;
  final String? breed;
  final Gender gender;
  final DateTime? birthDate;
  final bool confirmedBirthDate;
  final DateTime? admissionDate;
  final AdmissionType? admissionType;
  final DateTime? fillingDate;
  // final status;
  int? rabbitGroupId;
  int? regionId;

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      if (color != null) 'color': color,
      if (breed != null) 'breed': breed,
      'gender': gender,
      if (birthDate != null) 'birthDate': birthDate!.toIso8601String(),
      'confirmedBirthDate': confirmedBirthDate,
      if (admissionDate != null)
        'admissionDate': admissionDate!.toIso8601String(),
      if (admissionType != null) 'admissionType': admissionType,
      if (fillingDate != null) 'fillingDate': fillingDate!.toIso8601String(),
      // if (status != null)
      // 'status': status,
      if (rabbitGroupId != null) 'rabbitGroupId': rabbitGroupId,
      if (regionId != null) 'regionId': regionId,
    };
  }
}
