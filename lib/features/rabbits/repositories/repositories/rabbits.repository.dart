import 'package:spk_app_frontend/common/models/paginated.dto.dart';
import 'package:spk_app_frontend/common/services/gql.service.dart';
import 'package:spk_app_frontend/features/rabbits/models/dto.dart';
import 'package:spk_app_frontend/features/rabbits/models/models.dart';
import 'package:spk_app_frontend/features/rabbits/repositories/interfaces/rabbits.repo.interface.dart';

part 'rabbits.queries.dart';

class RabbitsRepository implements IRabbitsRepository {
  RabbitsRepository(this.gqlService);

  final GqlService gqlService;

  @override
  Future<Paginated<RabbitGroup>> findAll(
      FindRabbitsArgs args, bool totalCount) async {
    final result = await gqlService.query(
      GetRabbitsListQuery.document(totalCount),
      operationName: GetRabbitsListQuery.operationName,
      variables: args.toJson(),
    );

    if (result.hasException) {
      throw Exception(result.exception);
    }
    return Paginated.fromJson(
        result.data!['rabbitGroups'], RabbitGroup.fromJson);
  }

  @override
  Future<Rabbit> findOne(int id) async {
    final result = await gqlService.query(
      GetRabbitQuery.document,
      operationName: GetRabbitQuery.operationName,
      variables: {'id': id},
    );

    if (result.hasException) {
      throw Exception(result.exception);
    }

    return Rabbit.fromJson(result.data!['rabbit']);
  }

  @override
  Future<int> createRabbit(RabbitCreateDto rabbit) async {
    final result = await gqlService.mutate(
      CreateRabbitMutation.document,
      operationName: CreateRabbitMutation.operationName,
      variables: {'createRabbitInput': rabbit},
    );

    if (result.hasException) {
      throw Exception(result.exception);
    }

    return int.parse(result.data!['createRabbit']['id']);
  }

  @override
  Future<void> updateRabbit(RabbitUpdateDto rabbit) async {
    final result = await gqlService.mutate(
      UpdateRabbitMutation.document,
      operationName: UpdateRabbitMutation.operationName,
      variables: {'updateRabbitInput': rabbit},
    );

    if (result.hasException) {
      throw Exception(result.exception);
    }
  }

  @override
  Future<void> updateTeam(String rabbitGroupId, String teamId) async {
    final result = await gqlService.mutate(
      UpdateTeamMutation.document,
      operationName: UpdateTeamMutation.operationName,
      variables: {
        'rabbitGroupId': rabbitGroupId,
        'teamId': teamId,
      },
    );

    if (result.hasException) {
      throw result.exception!;
    }
  }

  @override
  Future<void> updateRabbitGroup(int rabbitId, int rabbitGroupId) async {
    final result = await gqlService.mutate(
      UpdateRabbitGroupMutation.document,
      operationName: UpdateRabbitGroupMutation.operationName,
      variables: {
        'rabbitId': rabbitId,
        'rabbitGroupId': rabbitGroupId,
      },
    );

    if (result.hasException) {
      throw result.exception!;
    }
  }

  @override
  Future<void> removeRabbit(int rabbitId) async {
    final result = await gqlService.mutate(
      RemoveRabbitMutation.document,
      operationName: RemoveRabbitMutation.operationName,
      variables: {'id': rabbitId},
    );

    if (result.hasException) {
      throw result.exception!;
    }
  }
}
