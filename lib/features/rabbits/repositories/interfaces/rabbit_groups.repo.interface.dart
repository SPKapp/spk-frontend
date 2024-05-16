import 'package:spk_app_frontend/features/rabbits/models/models.dart';

abstract class IRabbitGroupsRepository {
  /// Fetches [RabbitGroup] with given [id].
  Future<RabbitGroup> findOne(String id);
}
