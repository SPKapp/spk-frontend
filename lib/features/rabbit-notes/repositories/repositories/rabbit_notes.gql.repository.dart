import 'package:spk_app_frontend/common/models/paginated.dto.dart';
import 'package:spk_app_frontend/common/services/gql.service.dart';
import 'package:spk_app_frontend/features/rabbit-notes/models/dto.dart';
import 'package:spk_app_frontend/features/rabbit-notes/models/models.dart';
import 'package:spk_app_frontend/features/rabbit-notes/repositories/interfaces.dart';

part './rabbit_notes.queries.dart';

class GqlRabbitNotesRepository implements IRabbitNoteRepository {
  GqlRabbitNotesRepository(GqlService gqlService) : _gqlService = gqlService;

  final GqlService _gqlService;

  @override
  Future<Paginated<RabbitNote>> findAll(
      FindRabbitNotesArgs args, bool totalCount) async {
    final result = await _gqlService.query(
        GetRabbitNotesQuery.document(totalCount),
        operationName: GetRabbitNotesQuery.operationName,
        variables: args.toJson());

    if (result.hasException) {
      // TODO: Better error handling - own exception and print the error message to the user
      throw Exception(result.exception);
    }

    return Paginated.fromJson(result.data!['rabbitNotes'], RabbitNote.fromJson);
  }
}
