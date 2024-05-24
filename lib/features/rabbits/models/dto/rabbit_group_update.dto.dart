import 'package:spk_app_frontend/features/rabbits/models/models.dart';

final class RabbitGroupUpdateDto {
  RabbitGroupUpdateDto({
    required this.id,
    this.adoptionDescription,
    this.adoptionDate,
    this.status,
  });

  final String id;
  final String? adoptionDescription;
  final DateTime? adoptionDate;
  final RabbitGroupStatus? status;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      if (adoptionDescription != null)
        'adoptionDescription': adoptionDescription,
      if (adoptionDate != null) 'adoptionDate': adoptionDate!.toIso8601String(),
      if (status != null) 'status': status
    };
  }
}
