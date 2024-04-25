import 'package:spk_app_frontend/common/models/paginated.dto.dart';

import 'package:spk_app_frontend/features/rabbits/models/dto.dart';
import 'package:spk_app_frontend/features/rabbits/models/models.dart';

abstract interface class IRabbitsRepository {
  Future<List<RabbitGroup>> myRabbits();

  Future<Paginated<RabbitGroup>> findAll({
    bool totalCount = false,
    int? offset,
    int? limit,
    List<int>? regionsIds,
  });

  Future<Paginated<Rabbit>> findRabbitsByName(
    String name, {
    bool totalCount = false,
    int? offset,
    int? limit,
  });

  /// Retrieves a single [Rabbit] object based on the provided [id].
  Future<Rabbit> findOne(int id);

  /// Creates a new rabbit.
  Future<int> createRabbit(RabbitCreateDto rabbit);

  /// Updates a rabbit.
  Future<void> updateRabbit(RabbitUpdateDto rabbit);

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

  /// Removes a rabbit with the given [id].
  Future<void> removeRabbit(int id);
}
