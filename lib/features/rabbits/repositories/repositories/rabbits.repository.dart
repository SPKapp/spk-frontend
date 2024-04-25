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
  Future<List<RabbitGroup>> myRabbits() async {
    final result = await gqlService.query(_myRabbitsQuery);

    if (result.hasException) {
      throw Exception(result.exception);
    }

    return (result.data?['myProfile']['team']['rabbitGroups'] as List)
        .map((json) => RabbitGroup.fromJson(json))
        .toList();
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
  Future<void> updateTeam(int rabbitGroupId, int teamId) async {
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

  @override
  Future<Paginated<RabbitGroup>> findAll({
    bool totalCount = false,
    int? offset,
    int? limit,
    List<int>? regionsIds,
  }) async {
    final result = await gqlService.query(
      _getRabbitsListQuery(totalCount),
      variables: {
        if (offset != null) 'offset': offset,
        if (limit != null) 'limit': limit,
        if (regionsIds != null) 'regionId': regionsIds,
      },
    );

    if (result.hasException) {
      throw Exception(result.exception);
    }
    return Paginated.fromJson(
        result.data!['rabbitGroups'], RabbitGroup.fromJson);
  }

  @override
  Future<Paginated<Rabbit>> findRabbitsByName(
    String name, {
    bool totalCount = false,
    int? offset,
    int? limit,
  }) async {
    return const Paginated(
      data: [
        Rabbit(
          id: 1,
          name: 'Timon',
          gender: Gender.male,
          confirmedBirthDate: false,
          admissionType: AdmissionType.found,
        ),
        Rabbit(
            id: 1,
            name: 'Timon2',
            gender: Gender.male,
            confirmedBirthDate: false,
            admissionType: AdmissionType.found)
      ],
      totalCount: 2,
    );
  }
}
