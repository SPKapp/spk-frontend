import 'package:spk_app_frontend/common/storage/errors/errors.dart';

/// {@template storage_repository}
/// The interface for the storage repository.
///
///  For more information, see the `package:spk_app_frontend/common/storage/storage.dart`.
/// {@endtemplate}
abstract class IStorageRepository {
  /// {@template storage_repository.init}
  /// Initialize the repository.
  ///
  /// This method should be called before any other method.
  /// {@endtemplate}
  Future<void> init();

  /// {@template storage_repository.dispose}
  /// Dispose the repository.
  ///
  /// This method should be called when the repository is no longer needed.
  /// {@endtemplate}
  Future<void> close();

  /// {@template storage_repository.setToken}
  /// Set the token for the storage.
  /// If the error occurs, the [StorageTokenNotSetExeption] will be thrown.
  /// {@endtemplate}
  Future<void> setToken(String token);

  /// {@template storage_repository.getUserId}
  /// Get the user ID for the storage.
  /// {@endtemplate}
  String getUserId();
}
