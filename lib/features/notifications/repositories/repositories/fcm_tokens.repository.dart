import 'package:spk_app_frontend/common/services/gql.service.dart';
import 'package:spk_app_frontend/features/notifications/repositories/interfaces/fcm_tokens.repo.interface.dart';

part 'fcm_tokens.queries.dart';

final class FcmTokensRepository implements IFcmTokensRepository {
  FcmTokensRepository(this._gqlService);

  final GqlService _gqlService;

  @override
  Future<void> update(String token) async {
    final result = await _gqlService.mutate(
      UpdateFcmTokenMutation.document,
      operationName: UpdateFcmTokenMutation.operationName,
      variables: {'token': token},
    );

    if (result.hasException) {
      throw Exception(result.exception);
    }
  }

  @override
  Future<void> delete(String token) async {
    final result = await _gqlService.mutate(
      DeleteFcmTokenMutation.document,
      operationName: DeleteFcmTokenMutation.operationName,
      variables: {'token': token},
    );

    if (result.hasException) {
      throw Exception(result.exception);
    }
  }
}
