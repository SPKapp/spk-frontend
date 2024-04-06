import 'package:equatable/equatable.dart';

import 'package:spk_app_frontend/features/rabbits/models/models/rabbit.model.dart';

import 'package:spk_app_frontend/features/regions/models/models.dart';
import 'package:spk_app_frontend/features/users/models/models.dart';

final class RabbitGroup extends Equatable {
  const RabbitGroup({
    required this.id,
    required this.rabbits,
    this.team,
    this.region,
  });

  final int id;
  final List<Rabbit> rabbits;
  final Team? team;
  final Region? region;

  static RabbitGroup fromJson(Map<String, dynamic> json) {
    return RabbitGroup(
      id: int.parse(json['id']),
      rabbits: (json['rabbits'] as List)
          .map((e) => Rabbit.fromJson(e as Map<String, dynamic>))
          .toList(),
      team: json['team'] != null ? Team.fromJson(json['team']) : null,
      region: json['region'] != null ? Region.fromJson(json['region']) : null,
    );
  }

  @override
  List<Object?> get props => [
        id,
        rabbits,
        team,
        region,
      ];
}
