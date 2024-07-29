import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

import 'package:spk_app_frontend/common/bloc/debounce.transformer.dart';
import 'package:spk_app_frontend/common/services/logger.service.dart';
import 'package:spk_app_frontend/common/storage/storage.dart';
import 'package:spk_app_frontend/features/rabbit_photos/models/models.dart';
import 'package:spk_app_frontend/features/rabbit_photos/repositories/interfaces.dart';
import 'package:spk_app_frontend/features/rabbit_photos/repositories/repositories.dart';

part 'rabbit_photos.event.dart';
part 'rabbit_photos.state.dart';

/// The bloc for managing rabbit photos
///
/// Available events:
/// - [RabbitPhotosLoadPhotos] - initiates the loading of photos from the storage.
/// - [RabbitPhotosGetDefaultPhoto] - initiates the loading of the default photo from the storage.
/// - [RabbitPhotosSetDefaultPhoto] - sets the photo with the given [photoId] as the default photo for the rabbit.
///
/// Available states:
/// - [RabbitPhotosInitial] - the initial state.
/// - [RabbitPhotosList] - the state with the list of photos.
/// - [RabbitPhotosFailure] - the state with the error.
///
class RabbitPhotosBloc extends Bloc<RabbitPhotosEvent, RabbitPhotosState> {
  RabbitPhotosBloc({
    required this.rabbitId,
    required this.storageAuthRepository,
    @visibleForTesting IRabbitPhotoDownloadRepository? photosRepositroy,
  })  : _photosRepositroy = photosRepositroy ??
            RabbitPhotosFirebaseStorageRepositroy(rabbitId: rabbitId),
        super(RabbitPhotosInitial()) {
    _ensureInitialized = init();
    on<RabbitPhotosLoadPhotos>(_onLoadPhotos);
    on<_RabbitPhotosEmmitPhotos>(
      _onEmmitPhotos,
      transformer: debounceTransformer(const Duration(milliseconds: 500)),
    );
    on<_RabbitPhotosEmmitPhotosError>(_onEmmitPhotosError);
    on<_RabbitPhotosEmmitDefaultPhoto>(_onEmmitDefaultPhoto);
    on<RabbitPhotosGetDefaultPhoto>(_onGetDefaultPhoto);
    on<RabbitPhotosSetDefaultPhoto>(_onSetDefaultPhoto);
  }

  final String rabbitId;
  final IStorageAuthRepository storageAuthRepository;
  final IRabbitPhotoDownloadRepository _photosRepositroy;
  final _logger = LoggerService();
  late final StreamSubscription<(String, Photo)> _photosSubscription;

  /// This future is used to ensure that the initialization is done before any other operation.
  /// Should be awaited in all event handlers.
  late final Future<void> _ensureInitialized;
  Future<void> init() async {
    await _photosRepositroy.init();

    _photosSubscription = _photosRepositroy.photosStream.listen(
      _onRecivePhoto,
      onError: _onRecivePhotoError,
    );
  }

  @override
  Future<void> close() async {
    await _photosSubscription.cancel();
    await _photosRepositroy.close();
    return await super.close();
  }

  /// The token for accessing the storage
  String? _token;

  /// The list of photo names
  List<String> _names = [];
  final Map<String, Photo> _photos = {};
  String? _defaultPhotoId;

  /// The method to authenticate to the storage.
  ///
  /// It should be called before starting operations on the storage.
  /// If the [force] parameter is set to true, the token will be refreshed,
  /// even if it is already set.
  @visibleForTesting
  Future<void> authenticate({
    bool force = false,
  }) async {
    if (_token != null && !force) {
      return;
    }

    _token = await storageAuthRepository.getTokenForRabbitPhotos(rabbitId);
    await _photosRepositroy.setToken(_token!);
  }

  /// The event handler for the [RabbitPhotosLoadPhotos] event.
  /// It starts the loading of the photos from the storage.
  Future<void> _onLoadPhotos(
      RabbitPhotosLoadPhotos event, Emitter<RabbitPhotosState> emit) async {
    await _ensureInitialized;
    await authenticate();

    try {
      _names = await _photosRepositroy.listPhotos();
    } on StorageExeption catch (e) {
      if (e is StorageTokenExpiredExeption || e is StorageTokenNotSetExeption) {
        await authenticate(force: true);
        // Retry
        if (event is _RabbitPhotosLoadPhotosAfterSetToken) {
          // Avoid infinite loop
          _logger.error('Token expired after refresh', error: e);
          emit(RabbitPhotosFailure(code: e));
          return;
        }
        add(const _RabbitPhotosLoadPhotosAfterSetToken());
        return;
      } else {
        _logger.error('Error when listing photos', error: e);
        emit(RabbitPhotosFailure(code: e));
        return;
      }
    } catch (e) {
      // This should not happen
      _logger.error('Unknown error when listing photos', error: e);
      emit(const RabbitPhotosFailure(code: StorageUnknownExeption()));
      return;
    }

    emit(RabbitPhotosList(names: _names, photos: _photos));

    // Result will be received in the stream
    _photosRepositroy.getPhotos(_names);

    // remove old photos that no longer exist
    for (final oldPhoto in _photos.keys) {
      if (!_names.contains(oldPhoto)) {
        _photos.remove(oldPhoto);
      }
    }
  }

  /// The event handler for the [_RabbitPhotosEmmitPhotos] event.
  /// It emits the current state with the list of photos, is called after the photo is received.
  Future<void> _onEmmitPhotos(
      _RabbitPhotosEmmitPhotos event, Emitter<RabbitPhotosState> emit) async {
    _logger.debug(
        'Emit photos: ${RabbitPhotosList(names: _names, photos: _photos)}');
    emit(RabbitPhotosList(names: _names, photos: _photos));
  }

  /// The event handler for the [_RabbitPhotosEmmitPhotosError] event.
  /// It emits the current state with the error, is called after the error is received.
  Future<void> _onEmmitPhotosError(_RabbitPhotosEmmitPhotosError event,
      Emitter<RabbitPhotosState> emit) async {
    emit(RabbitPhotosFailure(code: event.error));
  }

  Future<void> _onEmmitDefaultPhoto(_RabbitPhotosEmmitDefaultPhoto event,
      Emitter<RabbitPhotosState> emit) async {
    emit(RabbitPhotosDefaultPhoto(photo: event.photo));
  }

  /// The method to handle the received photo.
  void _onRecivePhoto((String, Photo) data) async {
    final (name, photo) = data;

    if (_defaultPhotoId == name) {
      add(_RabbitPhotosEmmitDefaultPhoto(photo));
      _defaultPhotoId = null;
      return;
    }

    if (!_names.contains(name)) {
      return;
    }
    _photos[name] = photo;

    _logger.debug('Photo received: $name');
    add(const _RabbitPhotosEmmitPhotos());
  }

  /// The method to handle the error when receiving the photo.
  void _onRecivePhotoError(Object error) async {
    if (error is StorageExeption) {
      if (error is StorageTokenExpiredExeption ||
          error is StorageTokenNotSetExeption) {
        // This also continues the loading of the photos
        await authenticate(force: true);
        return;
      } else if (error is StorageFileExeption) {
        _logger.error('Error when receiving photo', error: error);
        if (error.fileId != null) {
          _photos[error.fileId!] = Photo.error();
          add(const _RabbitPhotosEmmitPhotos());
        }
        return;
      } else if (error is StorageNotInitializedExeption) {
        _logger.error('Storage not initialized', error: error);
        // Thats a bug, should not happen
        throw error;
      }
    }
    _logger.error('Unknown error when receiving photo', error: error);
    if (error is StorageExeption) {
      add(_RabbitPhotosEmmitPhotosError(error));
    } else {
      add(const _RabbitPhotosEmmitPhotosError(StorageUnknownExeption()));
    }
  }

  /// The event handler for the [RabbitPhotosGetDefaultPhoto] event.
  Future<void> _onGetDefaultPhoto(RabbitPhotosGetDefaultPhoto event,
      Emitter<RabbitPhotosState> emit) async {
    await _ensureInitialized;
    await authenticate();

    try {
      final name = await _photosRepositroy.getDefaultPhotoName();
      if (name == null) {
        emit(const RabbitPhotosFailure(code: StorageUnknownExeption()));
        return;
      }
      _defaultPhotoId = name;
      _photosRepositroy.getPhoto(name);
    } on StorageExeption catch (e) {
      if (e is StorageTokenExpiredExeption || e is StorageTokenNotSetExeption) {
        await authenticate(force: true);
        // Retry
        if (event is _RabbitPhotosLoadPhotosAfterSetToken) {
          // Avoid infinite loop
          _logger.error('Token expired after refresh', error: e);
          emit(RabbitPhotosFailure(code: e));
          return;
        }
        add(const _RabbitPhotosLoadPhotosAfterSetToken());
        return;
      } else {
        _logger.error('Error when listing photos', error: e);
        emit(RabbitPhotosFailure(code: e));
        return;
      }
    } catch (e) {
      // This should not happen
      _logger.error('Unknown error when listing photos', error: e);
      emit(const RabbitPhotosFailure(code: StorageUnknownExeption()));
      return;
    }
  }

  /// The event handler for the [RabbitPhotosSetDefaultPhoto] event.
  Future<void> _onSetDefaultPhoto(RabbitPhotosSetDefaultPhoto event,
      Emitter<RabbitPhotosState> emit) async {
    await _photosRepositroy.setDefaultPhotoName(event.photoId);

    for (final name in _photos.keys) {
      if (_photos[name] != null) {
        if (name == event.photoId) {
          _photos[name] = _photos[name]!.copyWith(isDefault: true);
        } else {
          _photos[name] = _photos[name]!.copyWith(isDefault: false);
        }
      }
    }
    emit(RabbitPhotosList(names: _names, photos: _photos));
  }
}
