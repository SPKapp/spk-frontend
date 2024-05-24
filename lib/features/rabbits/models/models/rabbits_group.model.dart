import 'package:equatable/equatable.dart';

import 'package:spk_app_frontend/features/rabbits/models/enums/group_status.enum.dart';
import 'package:spk_app_frontend/features/rabbits/models/models/rabbit.model.dart';

import 'package:spk_app_frontend/features/regions/models/models.dart';
import 'package:spk_app_frontend/features/users/models/models.dart';

final class RabbitGroup extends Equatable {
  const RabbitGroup({
    required this.id,
    this.adoptionDescription,
    this.adoptionDate,
    this.status,
    required this.rabbits,
    this.team,
    this.region,
  });

  final String id;
  final String? adoptionDescription;
  final DateTime? adoptionDate;
  final RabbitGroupStatus? status;
  final List<Rabbit> rabbits;
  final Team? team;
  final Region? region;

  static RabbitGroup fromJson(Map<String, dynamic> json) {
    return RabbitGroup(
      id: json['id'] as String,
      adoptionDescription: json['adoptionDescription'] as String?,
      adoptionDate: json['adoptionDate'] != null
          ? DateTime.parse(json['adoptionDate'])
          : null,
      status: json['status'] != null
          ? RabbitGroupStatus.fromJson(json['status'])
          : RabbitGroupStatus.unknown,
      rabbits: (json['rabbits'] as List)
          .map((e) => Rabbit.fromJson(e as Map<String, dynamic>))
          .toList(),
      team: json['team'] != null ? Team.fromJson(json['team']) : null,
      region: json['region'] != null ? Region.fromJson(json['region']) : null,
    );
  }

  String get name => rabbits.map((rabbit) => rabbit.name).join(', ');

  @override
  List<Object?> get props => [
        id,
        adoptionDescription,
        adoptionDate,
        rabbits,
        team,
        region,
      ];
}
