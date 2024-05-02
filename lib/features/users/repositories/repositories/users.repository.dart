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
  Future<Paginated<Team>> findAll(
    FindUsersArgs args,
    bool totalCount,
  ) async {
    final result = await _gqlService.query(GetTeamQuery.document(totalCount),
        operationName: GetTeamQuery.operationName, variables: args.toJson());

    if (result.hasException) {
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
