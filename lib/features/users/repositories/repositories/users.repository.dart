import 'package:spk_app_frontend/common/models/paginated.dto.dart';
import 'package:spk_app_frontend/common/services/gql.service.dart';

import 'package:spk_app_frontend/features/users/models/dto.dart';
import 'package:spk_app_frontend/features/users/models/models.dart';
import 'package:spk_app_frontend/features/users/repositories/interfaces.dart';

part 'users.queries.dart';

final class UsersRepository implements IUsersRepository {
  UsersRepository(this._gqlService);

  final GqlService _gqlService;

  @override
  Future<Paginated<Team>> fetchTeams({
    bool totalCount = false,
    int? offset,
    int? limit,
    List<int>? regionsIds,
    List<bool>? active,
  }) async {
    final result =
        await _gqlService.query(_getTeamListQuery(totalCount), variables: {
      if (offset != null) 'offset': offset,
      if (limit != null) 'limit': limit,
      if (regionsIds != null) 'regionsIds': regionsIds,
    });

    if (result.hasException) {
      // TODO: add exception handling
      throw Exception(result.exception);
    }

    return Paginated.fromJson<Team>(
      result.data!['teams'],
      (json) => Team.fromJson(json),
    );
  }

  @override
  Future<User> fetchUser(int id) async {
    return const User(
      id: 1,
      firstName: 'John',
      lastName: 'Doe',
      email: 'email@example.com',
      phone: '123456789',
    );
  }

  @override
  Future<int> createUser(UserCreateDto userCreateDto) async {
    return 1;
  }

  @override
  Future<Paginated<User>> findUsersByName(
    String name, {
    bool totalCount = false,
    int? offset,
    int? limit,
  }) async {
    return const Paginated(data: [
      User(
        id: 1,
        firstName: 'John',
        lastName: 'Doe',
        email: 'email@example.com',
        phone: '123456789',
      ),
      User(
        id: 2,
        firstName: 'John',
        lastName: 'Doe',
        email: 'email@example.com',
        phone: '123456789',
      ),
    ], totalCount: 2);
  }
}
