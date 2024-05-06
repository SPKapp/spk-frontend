import 'package:spk_app_frontend/common/services/gql.service.dart';
import 'package:spk_app_frontend/features/auth/auth.dart';
import 'package:spk_app_frontend/features/users/repositories/interfaces/permissions.repo.interface.dart';

part './permissions.queries.dart';

final class PermissionsRepository implements IPermissionsRepository {
  PermissionsRepository(this._gqlService);

  final GqlService _gqlService;

  @override
  Future<void> addRoleToUser(
    String userId,
    Role role, {
    String? teamId,
    String? regionId,
  }) async {
    final result = await _gqlService.mutate(
      AddRoleToUserMutation.document,
      operationName: AddRoleToUserMutation.operationName,
      variables: {
        'userId': userId,
        'role': role.jsonValue,
        'teamId': teamId,
        'regionId': regionId,
      },
    );

    if (result.hasException) {
      throw Exception(result.exception);
    }
  }

  @override
  Future<void> removeRoleFromUser(
    String userId,
    Role role, {
    String? regionId,
  }) async {
    final result = await _gqlService.mutate(
      RemoveRoleFromUserMutation.document,
      operationName: RemoveRoleFromUserMutation.operationName,
      variables: {
        'userId': userId,
        'role': role.jsonValue,
        'regionId': regionId,
      },
    );

    if (result.hasException) {
      throw Exception(result.exception);
    }
  }
}
