import 'package:equatable/equatable.dart';

import 'package:spk_app_frontend/features/rabbits/models/rabbit.model.dart';

final class RabbitGroup extends Equatable {
  const RabbitGroup({
    required this.id,
    required this.rabbits,
  });

  final int id;
  final List<Rabbit> rabbits;

  static RabbitGroup fromJson(Map<String, dynamic> json) {
    return RabbitGroup(
      id: int.parse(json['id']),
      rabbits: (json['rabbits'] as List)
          .map((e) => Rabbit.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  @override
  List<Object> get props => [id, rabbits];
}
