/// {@template storage_auth_repository}
/// The interface for the storage auth repository.
///
/// This repository is responsible for getting the token for the storage.
/// Each function should return a token, which should be passed to the storage repository.
///
/// For more information, see the `package:spk_app_frontend/common/storage/storage.dart`.
///
/// {@endtemplate}
abstract interface class IStorageAuthRepository {
  /// {@template storage_auth_repository.getTokenForRabbitPhotos}
  /// Get a token for Rabbit Photos, the token should be used to authenticate with the storage.
  /// {@endtemplate}
  Future<String> getTokenForRabbitPhotos(String rabbitId);
}
