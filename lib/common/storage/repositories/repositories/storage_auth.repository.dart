import 'package:spk_app_frontend/common/services/gql.service.dart';
import 'package:spk_app_frontend/common/storage/repositories/interfaces/storage_auth.repo.interface.dart';

part 'storage_auth.queries.dart';

/// {@macro storage_auth_repository}
final class GqlStorageAuthRepository implements IStorageAuthRepository {
  /// {@macro storage_auth_repository}
  const GqlStorageAuthRepository(this._gqlService);

  final GqlService _gqlService;

  /// {@macro storage_auth_repository.getTokenForRabbitPhotos}
  @override
  Future<String> getTokenForRabbitPhotos(String rabbitId) async {
    final result = await _gqlService.query(
      GetRabbitPhotosTokenQuery.document,
      operationName: GetRabbitPhotosTokenQuery.operationName,
      variables: {'id': rabbitId},
    );

    if (result.hasException) {
      throw result.exception!;
    }

    return result.data!['rabbitPhotosToken']['token'] as String;
  }
}
