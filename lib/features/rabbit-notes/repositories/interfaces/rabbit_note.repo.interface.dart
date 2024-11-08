import 'package:spk_app_frontend/common/models/paginated.dto.dart';

import 'package:spk_app_frontend/features/rabbit-notes/models/dto.dart';
import 'package:spk_app_frontend/features/rabbit-notes/models/models.dart';

abstract interface class IRabbitNotesRepository {
  /// Retrieves a paginated list of [RabbitNote] objects based on the provided arguments.
  ///
  /// The [args] parameter specifies the criteria for filtering the [RabbitNote] objects. The [totalCount] parameter specifies whether the total number of objects should be included in the result, otherwise it will be null.
  Future<Paginated<RabbitNote>> findAll(
      FindRabbitNotesArgs args, bool totalCount);

  /// Retrieves a single [RabbitNote] object based on the provided [id].
  Future<RabbitNote> findOne(String id);

  /// Remove a [RabbitNote] from the database based on the provided [id].
  Future<void> remove(String id);

  /// Create a new [RabbitNote] object based on the provided [dto].
  /// Returns the id of the created object.
  Future<int> create(RabbitNoteCreateDto dto);

  /// Update a [RabbitNote] object based on the provided [id] and [dto].
  Future<void> update(RabbitNoteUpdateDto dto);
}
