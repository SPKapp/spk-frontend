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
    this.stauts,
  });

  final int id;
  final String name;
  final String? color;
  final String? breed;
  final Gender gender;
  final DateTime? birthDate;
  final bool confirmedBirthDate;
  final DateTime? admissionDate;
  final AdmissionType admissionType;
  final DateTime? fillingDate;
  final RabbitStatus? stauts;

  final double? weight;

  final RabbitGroup? rabbitGroup;

  static Rabbit fromJson(Map<String, dynamic> json) {
    return Rabbit(
      id: int.parse(json['id']),
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
      weight: json['weight'] != null ? double.parse(json['weight']) : null,
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
      ];
}
