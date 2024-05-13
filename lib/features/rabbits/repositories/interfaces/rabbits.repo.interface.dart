import 'package:spk_app_frontend/common/models/paginated.dto.dart';

import 'package:spk_app_frontend/features/rabbits/models/dto.dart';
import 'package:spk_app_frontend/features/rabbits/models/models.dart';

abstract interface class IRabbitsRepository {
  /// Retrieves a list of [RabbitGroup] objects based on the provided arguments.
  ///
  /// The [args] parameter specifies the criteria for filtering the [RabbitGroup] objects. The [totalCount] parameter specifies whether the total number of objects should be included in the result, otherwise it will be null.
  Future<Paginated<RabbitGroup>> findAll(FindRabbitsArgs args, bool totalCount);

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
  Future<void> updateTeam(String rabbitGroupId, String teamId);

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
