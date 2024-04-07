import 'package:spk_app_frontend/common/models/paginated.dto.dart';

import 'package:spk_app_frontend/features/rabbits/models/dto.dart';
import 'package:spk_app_frontend/features/rabbits/models/models.dart';

abstract interface class IRabbitsRepository {
  Future<List<RabbitGroup>> myRabbits();
  Future<Rabbit> rabbit(int id);
  Future<Paginated<RabbitGroup>> findAll({
    bool totalCount = false,
    int? offset,
    int? limit,
    List<int>? regionsIds,
  });
  Future<int> createRabbit(RabbitCreateDto rabbit);
  Future<int> updateRabbit(RabbitUpdateDto rabbit);

  Future<Paginated<Rabbit>> findRabbitsByName(
    String name, {
    bool totalCount = false,
    int? offset,
    int? limit,
  });

  /// Updates the team of a rabbit group.
  ///
  /// The [rabbitGroupId] parameter specifies the ID of the rabbit group to update.
  /// The [teamId] parameter specifies the ID of the new team for the rabbit group.
  ///
  /// Throws an exception if the update fails.
  Future<void> updateTeam(int rabbitGroupId, int teamId);

  /// Updates the rabbit group for a specific rabbit.
  ///
  /// The [rabbitId] parameter specifies the ID of the rabbit to update.
  /// The [rabbitGroupId] parameter specifies the ID of the new rabbit group.
  ///
  /// Throws an exception if the update fails.
  Future<void> updateRabbitGroup(int rabbitId, int rabbitGroupId);
}
