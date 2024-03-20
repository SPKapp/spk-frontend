import 'package:spk_app_frontend/features/rabbits/models/dto/rabbit_create.dto.dart';

// TODO: Add Status
final class RabbitUpdateDto extends RabbitCreateDto {
  RabbitUpdateDto({
    required this.id,
    required super.name,
    super.color,
    super.breed,
    super.gender,
    super.birthDate,
    super.confirmedBirthDate,
    super.admissionDate,
    super.admissionType,
    super.fillingDate,
    super.rabbitGroupId,
    super.regionId,
  });

  final int id;

  @override
  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = super.toJson();
    json['id'] = id;
    return json;
  }
}
