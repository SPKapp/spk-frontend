import 'package:spk_app_frontend/common/exceptions/repository.exception.dart';
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
      if (result.exception!.graphqlErrors[0].extensions?['originalError'] !=
          null) {
        switch (result.exception!.graphqlErrors[0].extensions?['originalError']
            ['error']) {
          case 'region-id-required':
            throw const RepositoryException(
              code: 'region-id-required',
            );
          case 'user-not-found':
            throw const RepositoryException(
              code: 'user-not-found',
            );
          case 'active-groups':
            throw const RepositoryException(
              code: 'active-groups',
            );
          case 'region-not-found':
            throw const RepositoryException(
              code: 'region-not-found',
            );
          case 'team-not-found':
            throw const RepositoryException(
              code: 'team-not-found',
            );
          case 'user-not-active':
            throw const RepositoryException(
              code: 'user-not-active',
            );
        }
      }

      throw result.exception!;
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
      if (result.exception!.graphqlErrors[0].extensions?['originalError'] !=
          null) {
        switch (result.exception!.graphqlErrors[0].extensions?['originalError']
            ['error']) {
          case 'region-id-required':
            throw const RepositoryException(
              code: 'region-id-required',
            );
          case 'user-not-found':
            throw const RepositoryException(
              code: 'user-not-found',
            );
          case 'active-groups':
            throw const RepositoryException(
              code: 'active-groups',
            );
        }
      }

      throw result.exception!;
    }
  }

  @override
  Future<void> deactivateUser(String userId) async {
    final result = await _gqlService.mutate(
      DeactivateUserMutation.document,
      operationName: DeactivateUserMutation.operationName,
      variables: {
        'userId': userId,
      },
    );

    if (result.hasException) {
      if (result.exception!.graphqlErrors[0].extensions?['originalError'] !=
          null) {
        switch (result.exception!.graphqlErrors[0].extensions?['originalError']
            ['error']) {
          case 'user-can-not-deactivate-himself':
            throw const RepositoryException(
              code: 'user-can-not-deactivate-himself',
            );
          case 'user-not-found':
            throw const RepositoryException(
              code: 'user-not-found',
            );
          case 'active-groups':
            throw const RepositoryException(
              code: 'active-groups',
            );
        }
      }

      throw result.exception!;
    }
  }

  @override
  Future<void> activateUser(String userId) async {
    final result = await _gqlService.mutate(
      ActivateUserMutation.document,
      operationName: ActivateUserMutation.operationName,
      variables: {
        'userId': userId,
      },
    );

    if (result.hasException) {
      if (result.exception!.graphqlErrors[0].extensions?['originalError'] !=
          null) {
        switch (result.exception!.graphqlErrors[0].extensions?['originalError']
            ['error']) {
          case 'user-not-found':
            throw const RepositoryException(
              code: 'user-not-found',
            );
        }
      }
      throw result.exception!;
    }
  }
}
