import 'package:spk_app_frontend/features/rabbits/models/models.dart';

final class RabbitUpdateDto {
  RabbitUpdateDto({
    required this.id,
    this.name,
    this.color,
    this.breed,
    this.gender,
    this.birthDate,
    this.confirmedBirthDate,
    this.admissionDate,
    this.admissionType,
    this.fillingDate,
    this.status,
  });

  final int id;
  final String? name;
  final String? color;
  final String? breed;
  final Gender? gender;
  final DateTime? birthDate;
  final bool? confirmedBirthDate;
  final DateTime? admissionDate;
  final AdmissionType? admissionType;
  final DateTime? fillingDate;
  final RabbitStatus? status;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      if (color != null) 'color': color,
      if (breed != null) 'breed': breed,
      if (gender != null) 'gender': gender,
      if (birthDate != null) 'birthDate': birthDate!.toIso8601String(),
      if (confirmedBirthDate != null) 'confirmedBirthDate': confirmedBirthDate,
      if (admissionDate != null)
        'admissionDate': admissionDate!.toIso8601String(),
      if (admissionType != null) 'admissionType': admissionType,
      if (fillingDate != null) 'fillingDate': fillingDate!.toIso8601String(),
      if (status != null) 'status': status,
    };
  }
}
