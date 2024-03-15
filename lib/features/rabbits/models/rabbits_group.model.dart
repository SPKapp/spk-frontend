import 'package:equatable/equatable.dart';

import 'package:spk_app_frontend/features/rabbits/models/rabbit.model.dart';

final class RabbitsGroup extends Equatable {
  const RabbitsGroup({
    required this.id,
    required this.rabbits,
  });

  final int id;
  final List<Rabbit> rabbits;

  @override
  List<Object> get props => [id, rabbits];
}
