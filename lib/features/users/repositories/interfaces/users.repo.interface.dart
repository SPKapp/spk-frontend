import 'package:spk_app_frontend/common/models/paginated.dto.dart';

import 'package:spk_app_frontend/features/users/models/dto.dart';
import 'package:spk_app_frontend/features/users/models/models.dart';

abstract interface class IUsersRepository {
  Future<Paginated<Team>> fetchTeams({
    bool totalCount = false,
    int? offset,
    int? limit,
    List<int>? regionsIds,
  });
  Future<User> fetchUser(int id);
  Future<int> createUser(UserCreateDto user);

  Future<Paginated<User>> findUsersByName(
    String name, {
    bool totalCount = false,
    int? offset,
    int? limit,
  });
}
