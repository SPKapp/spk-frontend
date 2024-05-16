import 'package:spk_app_frontend/features/rabbits/models/dto.dart';
import 'package:spk_app_frontend/features/rabbits/models/models.dart';

abstract class IRabbitGroupsRepository {
  /// Fetches [RabbitGroup] with given [id].
  Future<RabbitGroup> findOne(String id);

  /// Updates [RabbitGroup] with given [id] using [dto].
  Future<void> update(String id, RabbitGroupUpdateDto dto);
}
