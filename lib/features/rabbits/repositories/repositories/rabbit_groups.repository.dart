import 'package:spk_app_frontend/common/services/gql.service.dart';
import 'package:spk_app_frontend/features/rabbits/models/dto.dart';
import 'package:spk_app_frontend/features/rabbits/models/models.dart';
import 'package:spk_app_frontend/features/rabbits/repositories/interfaces/rabbit_groups.repo.interface.dart';

part 'rabbit_groups.queries.dart';

class RabbitGroupsRepository implements IRabbitGroupsRepository {
  RabbitGroupsRepository(this.gqlService);

  final GqlService gqlService;

  @override
  Future<RabbitGroup> findOne(String id) async {
    final result = await gqlService.query(
      _GetRabbitGroupQuery.document,
      operationName: _GetRabbitGroupQuery.operationName,
      variables: {'id': id},
    );

    if (result.hasException) {
      throw Exception(result.exception);
    }

    return RabbitGroup.fromJson(result.data!['rabbitGroup']);
  }

  @override
  Future<void> update(String id, RabbitGroupUpdateDto dto) async {
    final result = await gqlService.mutate(
      _UpdateRabbitGroupMutation.document,
      operationName: _UpdateRabbitGroupMutation.operationName,
      variables: {
        'updateDto': dto.toJson(),
      },
    );

    if (result.hasException) {
      throw Exception(result.exception);
    }
  }
}
