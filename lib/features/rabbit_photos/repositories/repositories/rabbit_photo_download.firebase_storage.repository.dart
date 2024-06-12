import 'dart:async';
import 'dart:collection';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';
import 'package:hive/hive.dart';
import 'package:meta/meta.dart';
import 'package:spk_app_frontend/common/services/logger.service.dart';

import 'package:spk_app_frontend/common/storage/storage.dart';
import 'package:spk_app_frontend/features/rabbit_photos/models/models.dart';
import 'package:spk_app_frontend/features/rabbit_photos/repositories/interfaces/rabbit_photo_download.repo.interface.dart';

final class RabbitPhotosFirebaseStorageRepositroy
    extends FirebaseStorageRepository
    implements IRabbitPhotoDownloadRepository {
  RabbitPhotosFirebaseStorageRepositroy({
    required this.rabbitId,
    @visibleForTesting super.firebaseAuth,
    @visibleForTesting super.firebaseStorage,
  }) : _path = 'rabbits/$rabbitId/photos/';

  @override
  Future<void> init() async {
    await super.init();

    _box = await Hive.openBox<Photo>('rabbitPhotos');
    _storageRef = firebaseStorage.ref(_path);
  }

  @override
  Future<void> dispose() async {
    // Clear the queues and wait for them to finish
    _cacheActualCheckQueue.clear();
    _downloadQueue.clear();
    await Future.doWhile(() => _isCacheActualCheckRunning);
    await Future.doWhile(() => _isDownloadLoopRunning);

    await super.dispose();
  }

  @override
  Future<void> setToken(String token) async {
    await super.setToken(token);

    // Restart loops with the new token
    _cacheActualCheckLoop();
    _downloadLoop();
  }

  final _logger = LoggerService();
  late final Box<Photo> _box;
  late final Reference _storageRef;
  final String _path;
  final String rabbitId;

  String _filePath(String photoId) => '$_path$photoId';

  /// {@macro rabbit_photos_repository.list_photos}
  ///
  /// This implementation also deletes old photos of this rabbit from the cache.
  @override
  Future<List<String>> listPhotos(String rabbitId) async {
    late final ListResult listResult;
    try {
      listResult = await _storageRef.listAll();
    } on FirebaseException catch (e) {
      final exeption = await parseFirebaseException(e);
      _logger.error('Failed to list photos for rabbit $rabbitId',
          error: exeption);
      throw exeption;
    } catch (e) {
      _logger.error('Failed to list photos for rabbit $rabbitId', error: e);
      throw const StorageUnknownExeption();
    }

    // Don't await this, it's can be done in the background
    SchedulerBinding.instance.scheduleTask(
      () => _deleteOldPhotosFromCache(
          listResult.items.map((photoRef) => photoRef.fullPath).toList()),
      Priority.animation,
    );

    return listResult.items.map((photoRef) => photoRef.name).toList();
  }

  /// This method deletes old photos from the cache.
  /// [newPhotos] is the list of new photos that should be in the cache,
  /// in the format of the full path of the photo.
  Future<void> _deleteOldPhotosFromCache(List<String> newPhotos) async {
    for (final oldPhoto in _box.keys.where((key) => key.startsWith(_path))) {
      if (!newPhotos.contains(oldPhoto)) {
        _logger.debug('Deleting old photo $oldPhoto from the cache');
        _box.delete(oldPhoto);
      }
    }
  }

  /// {@macro rabbit_photos_repository.get_photos}
  @override
  void getPhotos(List<String> photoIds) {
    for (final photoId in photoIds) {
      getPhoto(photoId);
    }
  }

  /// {@macro rabbit_photos_repository.get_photo}
  ///
  /// This implementation gets the photo from the cache if it's there and checks if it's actual.
  @override
  void getPhoto(String photoId) {
    final cachedPhoto = _box.get(_filePath(photoId));
    if (cachedPhoto != null) {
      _logger.debug('Photo $photoId is in the cache');
      _checkActualStateOfPhoto(photoId, cachedPhoto);
    } else {
      _logger.debug('Photo $photoId is not in the cache');
      _downloadPhoto(photoId);
    }
  }

  /// {@macro rabbit_photos_repository.photosStream}
  @override
  Stream<(String, Photo)> get photosStream => _photosController.stream;
  final _photosController = StreamController<(String, Photo)>();

  final Queue<(String, Photo)> _cacheActualCheckQueue = Queue();
  bool _isCacheActualCheckRunning = false;

  /// This method should be called after the photo is received from the cache.
  /// It enqueues the photo to check if it's actual.
  ///
  /// See [_cacheActualCheckLoop] for more details.
  void _checkActualStateOfPhoto(String photoId, Photo photo) {
    if (!_cacheActualCheckQueue.any((element) => element.$1 == photoId)) {
      _cacheActualCheckQueue.addFirst((photoId, photo));
      _cacheActualCheckLoop();
    }
  }

  final Queue<String> _downloadQueue = Queue();
  bool _isDownloadLoopRunning = false;

  /// This method is used to download the photo.
  ///
  /// It enqueues the photo to download it.
  ///
  /// See [_downloadLoop] for more details.
  void _downloadPhoto(String photoId) {
    if (!_downloadQueue.contains(photoId)) {
      _downloadQueue.addFirst(photoId);
      _downloadLoop();
    }
  }

  /// This method is used to check if the photo in the cache is actual.
  /// If the photo is not actual, it will be downloaded.
  Future<void> _cacheActualCheckLoop() async {
    if (_isCacheActualCheckRunning) {
      return;
    }
    _isCacheActualCheckRunning = true;

    while (_cacheActualCheckQueue.isNotEmpty) {
      final (photoId, photo) = _cacheActualCheckQueue.removeFirst();

      _logger.debug('Checking if photo $photoId is actual');

      try {
        final metadata = await _storageRef.child(photoId).getMetadata();
        if (photo.updatedAt != metadata.updated) {
          logger.debug(
              'Photo $photoId is not actual ${photo.updatedAt} != ${metadata.updated} (cache != storage)');
          await _box.delete(_filePath(photoId));
          _downloadPhoto(photoId);
        } else {
          _photosController.add((photoId, photo));
        }
      } on FirebaseException catch (e) {
        // Stop the loop if the token is expired, not set or the storage is not initialized
        if (await _processFirebaseException(e)) {
          _cacheActualCheckQueue.addFirst((photoId, photo));
          break;
        }
      } catch (e) {
        logger.error('Failed to check if photo $photoId is actual', error: e);
        _photosController.addError(StorageUnknownExeption(
          fileId: photoId,
        ));
        break;
      }
    }
    _isCacheActualCheckRunning = false;
  }

  /// This method is used to download the photos from the queue.
  /// It downloads the photos and adds them to the cache.
  Future<void> _downloadLoop() async {
    if (_isDownloadLoopRunning) {
      return;
    }
    _isDownloadLoopRunning = true;

    while (_downloadQueue.isNotEmpty) {
      final photoId = _downloadQueue.removeFirst();

      _logger.debug('Downloading photo $photoId');

      try {
        final metadata = await _storageRef.child(photoId).getMetadata();
        final data = await _storageRef.child(photoId).getData();

        if (data == null) {
          _photosController.addError(StorageUnknownExeption(
            fileId: photoId,
          ));
          continue;
        }

        final photo = Photo(
          data: data,
          updatedAt: metadata.updated ?? DateTime.now(),
          isDefault: false,
        );

        await _box.put(_filePath(photoId), photo);
        _photosController.add((photoId, photo));
      } on FirebaseException catch (e) {
        // Stop the loop if the token is expired, not set or the storage is not initialized
        if (await _processFirebaseException(e)) {
          _downloadQueue.addFirst(photoId);
          break;
        }
      } catch (e) {
        logger.error('Failed to download photo $photoId', error: e);
        _photosController.addError(StorageUnknownExeption(fileId: photoId));
      }
    }
    _isDownloadLoopRunning = false;
  }

  /// This method processes the Firebase exception.
  /// Returns `true` if the loop which called this method should be stopped.
  Future<bool> _processFirebaseException(FirebaseException e) async {
    final exeption = await parseFirebaseException(e);
    _photosController.addError(exeption);

    return exeption is StorageTokenExpiredExeption ||
        exeption is StorageTokenNotSetExeption ||
        exeption is StorageNotInitializedExeption;
  }
}