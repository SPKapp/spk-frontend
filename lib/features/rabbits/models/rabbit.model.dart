import 'package:equatable/equatable.dart';

import 'package:spk_app_frontend/features/rabbits/models/rabbits_group.model.dart';

final class Rabbit extends Equatable {
  const Rabbit({
    required this.id,
    required this.name,
    this.rabbitGroup,
  });

  final int id;
  final String name;

  final RabbitsGroup? rabbitGroup;

  static Rabbit fromJson(Map<String, dynamic> json) {
    return Rabbit(
      id: int.parse(json['id']),
      name: json['name'] as String,
      rabbitGroup: json['rabbitGroup'] != null
          ? RabbitsGroup.fromJson(json['rabbitGroup'])
          : null,
    );
  }

  @override
  List<Object> get props => [id, name];
}
