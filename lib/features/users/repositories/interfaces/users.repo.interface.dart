import 'package:spk_app_frontend/common/models/paginated.dto.dart';

import 'package:spk_app_frontend/features/users/models/dto.dart';
import 'package:spk_app_frontend/features/users/models/models.dart';

abstract interface class IUsersRepository {
  /// Retrieves a list of [User] objects based on the provided arguments.
  ///
  /// The [args] parameter specifies the criteria for filtering the [User] objects. The [totalCount] parameter specifies whether the total number of objects should be included in the result, otherwise it will be null.
  Future<Paginated<User>> findAll(FindUsersArgs args, bool totalCount);

  /// Retrieves a single [User] object based on the provided [id].
  Future<User> findOne(String id);

  /// Retrieves the current [User] object.
  Future<User> findMyProfile();

  /// Creates a new [User].
  Future<String> createUser(UserCreateDto user);

  /// Updates an existing [User].
  Future<void> updateUser(String id, UserUpdateDto user);

  /// Updates the current [User].
  Future<void> updateMyProfile(UserUpdateDto user);
}
