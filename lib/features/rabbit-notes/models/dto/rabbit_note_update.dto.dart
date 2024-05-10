import 'package:equatable/equatable.dart';

import 'package:spk_app_frontend/features/rabbit-notes/models/models.dart';

final class RabbitNoteUpdateDto extends Equatable {
  const RabbitNoteUpdateDto({
    required this.id,
    this.description,
    this.weight,
    this.vetVisit,
  });

  final String id;
  final String? description;
  final double? weight;
  final VetVisit? vetVisit;

  Map<String, dynamic> toJson() => {
        'id': id,
        if (description != null) 'description': description,
        if (weight != null) 'weight': weight,
        if (vetVisit != null) 'vetVisit': vetVisit?.toJson(),
      };

  @override
  List<Object?> get props => [id, description, weight, vetVisit];
}
