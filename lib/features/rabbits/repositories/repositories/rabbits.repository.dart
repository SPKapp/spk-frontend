import 'package:spk_app_frontend/common/models/paginated.dto.dart';
import 'package:spk_app_frontend/common/services/gql.service.dart';
import 'package:spk_app_frontend/features/rabbits/models/dto/dto.dart';
import 'package:spk_app_frontend/features/rabbits/models/models.dart';
import 'package:spk_app_frontend/features/rabbits/repositories/interfaces/rabbits.repo.interface.dart';

part 'rabbits.queries.dart';

class RabbitsRepository implements IRabbitsRepository {
  RabbitsRepository(this.gqlService);

  final GqlService gqlService;

  @override
  Future<List<RabbitsGroup>> myRabbits() async {
    final result = await gqlService.query(_myRabbitsQuery);

    if (result.hasException) {
      throw Exception(result.exception);
    }

    return (result.data?['myProfile']['team']['rabbitGroups'] as List)
        .map((json) => RabbitsGroup.fromJson(json))
        .toList();
  }

  @override
  Future<Rabbit> rabbit(int id) async {
    final result = await gqlService.query(_rabbitQuery, variables: {'id': id});

    if (result.hasException) {
      throw Exception(result.exception);
    }

    return Rabbit.fromJson(result.data!['rabbit']);
  }

  @override
  Future<int> createRabbit(RabbitCreateDto rabbit) async {
    final result = await gqlService.mutate(_createRabbitMutation,
        variables: {'createRabbitInput': rabbit});

    if (result.hasException) {
      throw Exception(result.exception);
    }

    return int.parse(result.data!['createRabbit']['id']);
  }

  @override
  Future<int> updateRabbit(RabbitUpdateDto rabbit) async {
    final result = await gqlService.mutate(_updateRabbitMutation,
        variables: {'updateRabbitInput': rabbit});

    if (result.hasException) {
      throw Exception(result.exception);
    }

    return int.parse(result.data!['updateRabbit']['id']);
  }

  @override
  Future<Paginated<RabbitsGroup>> findAll({
    bool totalCount = false,
    int? offset,
    int? limit,
  }) async {
    final result = await gqlService.query(
      _rabbitsQuery(totalCount),
      variables: {
        if (offset != null) 'offset': offset,
        if (limit != null) 'limit': limit,
      },
    );

    if (result.hasException) {
      throw Exception(result.exception);
    }
    return Paginated.fromJson(
        result.data!['rabbitGroups'], RabbitsGroup.fromJson);
  }
}