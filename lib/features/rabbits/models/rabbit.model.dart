import 'package:equatable/equatable.dart';

import 'package:spk_app_frontend/features/rabbits/models/gender.enum.dart';
import 'package:spk_app_frontend/features/rabbits/models/rabbits_group.model.dart';

final class Rabbit extends Equatable {
  const Rabbit({
    required this.id,
    required this.name,
    required this.gender,
    this.color,
    this.weight,
    this.birthDate,
    required this.confirmedBirthDate,
    this.rabbitGroup,
  });

  final int id;
  final String name;
  final Gender gender;
  final String? color;
  final double? weight;

  final DateTime? birthDate;
  final bool confirmedBirthDate;

  // AdmissionType? admissionType;

  final RabbitsGroup? rabbitGroup;

  static Rabbit fromJson(Map<String, dynamic> json) {
    return Rabbit(
      id: int.parse(json['id']),
      name: json['name'] as String,
      gender: json['gender'] != null
          ? Gender.fromJson(json['gender'])
          : Gender.unknown,
      color: json['color'] as String?,
      weight: json['weight'] != null ? double.parse(json['weight']) : null,
      birthDate:
          json['birthDate'] != null ? DateTime.parse(json['birthDate']) : null,
      confirmedBirthDate: json['confirmedBirthDate'] != null
          ? json['confirmedBirthDate'] as bool
          : false,
      rabbitGroup: json['rabbitGroup'] != null
          ? RabbitsGroup.fromJson(json['rabbitGroup'])
          : null,
    );
  }

  @override
  List<Object> get props => [id, name];
}
