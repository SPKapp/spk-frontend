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
  Future<Paginated<User>> findAll(
    FindUsersArgs args,
    bool totalCount,
  ) async {
    final result = await _gqlService.query(_GetUsersQuery.document(totalCount),
        operationName: _GetUsersQuery.operationName, variables: args.toJson());

    if (result.hasException) {
      throw Exception(result.exception);
    }

    return Paginated.fromJson<User>(
      result.data!['users'],
      User.fromJson,
    );
  }

  @override
  Future<User> findOne(String id) async {
    final result = await _gqlService.query(
      _GetUserQuery.document,
      operationName: _GetUserQuery.operationName,
      variables: {'id': id},
    );

    if (result.hasException) {
      throw Exception(result.exception);
    }

    return User.fromJson(result.data!['user']);
  }

  @override
  Future<User> findMyProfile() async {
    final result = await _gqlService.query(
      _GetMyProfileQuery.document,
      operationName: _GetMyProfileQuery.operationName,
    );

    if (result.hasException) {
      throw Exception(result.exception);
    }

    return User.fromJson(result.data!['myProfile']);
  }

  @override
  Future<String> createUser(UserCreateDto userCreateDto) async {
    final result = await _gqlService.mutate(
      _CreateUserMutation.document,
      operationName: _CreateUserMutation.operationName,
      variables: {'createUserInput': userCreateDto.toJson()},
    );

    if (result.hasException) {
      throw Exception(result.exception);
    }

    return result.data!['createUser']['id'] as String;
  }

  @override
  Future<void> updateUser(String id, UserUpdateDto userUpdateDto) async {
    final result = await _gqlService.mutate(
      _UpdateUserMutation.document,
      operationName: _UpdateUserMutation.operationName,
      variables: {
        'updateUserInput': userUpdateDto.toJson(),
      },
    );

    if (result.hasException) {
      throw Exception(result.exception);
    }
  }

  @override
  Future<void> updateMyProfile(UserUpdateDto userUpdateDto) async {
    final result = await _gqlService.mutate(
      _UpdateMyProfileMutation.document,
      operationName: _UpdateMyProfileMutation.operationName,
      variables: {
        'updateUserInput': userUpdateDto.toJson(),
      },
    );

    if (result.hasException) {
      throw Exception(result.exception);
    }
  }
}
