import 'package:equatable/equatable.dart';

import 'package:spk_app_frontend/features/rabbit-notes/models/models.dart';

final class RabbitNoteCreateDto extends Equatable {
  const RabbitNoteCreateDto({
    required this.rabbitId,
    required this.description,
    this.weight,
    this.vetVisit,
  });

  final String rabbitId;
  final String description;
  final double? weight;
  final VetVisit? vetVisit;

  Map<String, dynamic> toJson() => {
        'rabbitId': rabbitId,
        'description': description,
        if (weight != null) 'weight': weight,
        if (vetVisit != null) 'vetVisit': vetVisit?.toJson(),
      };

  @override
  List<Object?> get props => [rabbitId, description, weight, vetVisit];
}
