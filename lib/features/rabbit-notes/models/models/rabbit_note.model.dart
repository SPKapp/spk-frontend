import 'package:equatable/equatable.dart';

import 'package:spk_app_frontend/features/rabbit-notes/models/models/vet_visit.model.dart';

final class RabbitNote extends Equatable {
  const RabbitNote({
    required this.id,
    this.rabbitId,
    this.createdBy,
    this.description,
    this.weight,
    this.vetVisit,
    this.createdAt,
  });

  final String id;
  final String? rabbitId;
  final String? createdBy;
  final String? description;
  final double? weight;
  final VetVisit? vetVisit;
  final DateTime? createdAt;

  @override
  List<Object?> get props => [id, description, weight, vetVisit, createdAt];

  factory RabbitNote.fromJson(Map<String, dynamic> json) {
    return RabbitNote(
      id: json['id'] as String,
      rabbitId: json['rabbitId'] as String?,
      createdBy: json['createdBy'] as String?,
      description: json['description'] as String?,
      weight: json['weight'] is int
          ? (json['weight'] as int).toDouble()
          : json['weight'] as double?,
      vetVisit:
          json['vetVisit'] != null ? VetVisit.fromJson(json['vetVisit']) : null,
      createdAt:
          json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
    );
  }
}
