import 'package:spk_app_frontend/common/exceptions/repository.exception.dart';
import 'package:spk_app_frontend/common/storage/repositories/interfaces.dart';

/// Abstract class for the storage repository errors.
sealed class StorageExeption extends RepositoryException {
  const StorageExeption({required String code}) : super(code: 'storage_$code');

  @override
  String toString() {
    return 'StorageExeption: $code';
  }
}

/// The token is expired, add new token and try again.
final class StorageTokenExpiredExeption extends StorageExeption {
  const StorageTokenExpiredExeption() : super(code: 'expired');
}

/// The user is not authorized to access the resource.
final class StorageUnauthorizedExeption extends StorageExeption {
  const StorageUnauthorizedExeption({this.fileId})
      : super(code: 'unauthorized');

  final String? fileId;
}

/// The token is not set, the [IStorageRepository.setToken] should be called.
final class StorageTokenNotSetExeption extends StorageExeption {
  const StorageTokenNotSetExeption() : super(code: 'token_not_set');
}

/// The storage is not initialized, call [IStorageRepository.init] first.
final class StorageNotInitializedExeption extends StorageExeption {
  const StorageNotInitializedExeption() : super(code: 'not_initialized');
}

/// The file is not found in the storage.
final class StorageFileNotFoundExeption extends StorageExeption {
  const StorageFileNotFoundExeption(this.fileId)
      : super(code: 'file_not_found');

  final String fileId;
}

/// The error is unknown.
final class StorageUnknownExeption extends StorageExeption {
  const StorageUnknownExeption({
    this.fileId,
  }) : super(code: 'unknown');

  final String? fileId;
}
