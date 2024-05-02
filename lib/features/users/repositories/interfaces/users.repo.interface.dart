import 'package:spk_app_frontend/common/models/paginated.dto.dart';

import 'package:spk_app_frontend/features/users/models/dto.dart';
import 'package:spk_app_frontend/features/users/models/models.dart';

abstract interface class IUsersRepository {
  /// Retrieves a list of [Team] objects based on the provided arguments.
  ///
  /// The [args] parameter specifies the criteria for filtering the [Team] objects. The [totalCount] parameter specifies whether the total number of objects should be included in the result, otherwise it will be null.
  Future<Paginated<Team>> findAll(FindUsersArgs args, bool totalCount);

  Future<User> fetchUser(int id);
  Future<int> createUser(UserCreateDto user);

  Future<Paginated<User>> findUsersByName(
    String name, {
    bool totalCount = false,
    int? offset,
    int? limit,
  });
}
