final class RabbitGroupUpdateDto {
  RabbitGroupUpdateDto({
    required this.id,
    this.adoptionDescription,
    this.adoptionDate,
  });

  final String id;
  final String? adoptionDescription;
  final DateTime? adoptionDate;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      if (adoptionDescription != null)
        'adoptionDescription': adoptionDescription,
      if (adoptionDate != null) 'adoptionDate': adoptionDate!.toIso8601String(),
    };
  }
}
