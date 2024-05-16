import 'package:equatable/equatable.dart';

import 'package:spk_app_frontend/features/rabbits/models/enums/gender.enum.dart';
import 'package:spk_app_frontend/features/rabbits/models/enums/admission_type.enum.dart';
import 'package:spk_app_frontend/features/rabbits/models/enums/rabbit_status.enum.dart';
import 'package:spk_app_frontend/features/rabbits/models/models/rabbits_group.model.dart';

final class Rabbit extends Equatable {
  const Rabbit({
    required this.id,
    required this.name,
    this.color,
    this.breed,
    required this.gender,
    this.birthDate,
    required this.confirmedBirthDate,
    this.admissionDate,
    required this.admissionType,
    this.fillingDate,
    this.weight,
    this.rabbitGroup,
    this.status,
    this.chipNumber,
    this.castrationDate,
    this.dewormingDate,
    this.vaccinationDate,
  });

  final String id;

  /// Editable fields
  final String name;
  final String? color;
  final String? breed;
  final Gender gender;
  final DateTime? birthDate;
  final bool confirmedBirthDate;
  final DateTime? admissionDate;
  final AdmissionType admissionType;
  final DateTime? fillingDate;
  final RabbitStatus? status;

  /// Non-editable fields - from MedicalHistory
  final double? weight;
  final String? chipNumber;
  final DateTime? castrationDate;
  final DateTime? dewormingDate;
  final DateTime? vaccinationDate;

  final RabbitGroup? rabbitGroup;

  static Rabbit fromJson(Map<String, dynamic> json) {
    return Rabbit(
      id: json['id'],
      name: json['name'] as String,
      color: json['color'] as String?,
      breed: json['breed'] as String?,
      gender: json['gender'] != null
          ? Gender.fromJson(json['gender'])
          : Gender.unknown,
      birthDate:
          json['birthDate'] != null ? DateTime.parse(json['birthDate']) : null,
      confirmedBirthDate: json['confirmedBirthDate'] != null
          ? json['confirmedBirthDate'] as bool
          : false,
      admissionDate: json['admissionDate'] != null
          ? DateTime.parse(json['admissionDate'])
          : null,
      admissionType: json['admissionType'] != null
          ? AdmissionType.fromJson(json['admissionType'])
          : AdmissionType.found,
      fillingDate: json['fillingDate'] != null
          ? DateTime.parse(json['fillingDate'])
          : null,
      status: json['status'] != null
          ? RabbitStatus.fromJson(json['status'])
          : RabbitStatus.unknown,
      weight: json['weight'] is int
          ? (json['weight'] as int).toDouble()
          : json['weight'] as double?,
      chipNumber: json['chipNumber'] as String?,
      castrationDate: json['castrationDate'] != null
          ? DateTime.parse(json['castrationDate'])
          : null,
      dewormingDate: json['dewormingDate'] != null
          ? DateTime.parse(json['dewormingDate'])
          : null,
      vaccinationDate: json['vaccinationDate'] != null
          ? DateTime.parse(json['vaccinationDate'])
          : null,
      rabbitGroup: json['rabbitGroup'] != null
          ? RabbitGroup.fromJson(json['rabbitGroup'])
          : null,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        color,
        breed,
        gender,
        birthDate,
        confirmedBirthDate,
        admissionDate,
        admissionType,
        fillingDate,
        status,
        weight,
        chipNumber,
        castrationDate,
        dewormingDate,
        vaccinationDate,
        rabbitGroup,
      ];
}
