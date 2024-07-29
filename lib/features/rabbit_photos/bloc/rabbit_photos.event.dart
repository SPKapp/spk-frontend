part of 'rabbit_photos.bloc.dart';

sealed class RabbitPhotosEvent extends Equatable {
  const RabbitPhotosEvent();

  @override
  List<Object> get props => [];
}

/// This event initiates the loading of photos from the storage.
final class RabbitPhotosLoadPhotos extends RabbitPhotosEvent {
  const RabbitPhotosLoadPhotos();
}

/// Works like [RabbitPhotosLoadPhotos], but prevents reauth loop.
final class _RabbitPhotosLoadPhotosAfterSetToken
    extends RabbitPhotosLoadPhotos {
  const _RabbitPhotosLoadPhotosAfterSetToken();
}

/// This event emmits the photos to the UI.
/// Used to emit the photos received from the storage.
final class _RabbitPhotosEmmitPhotos extends RabbitPhotosEvent {
  const _RabbitPhotosEmmitPhotos();
}

/// Like [_RabbitPhotosEmmitPhotos], but emits an error.
final class _RabbitPhotosEmmitPhotosError extends RabbitPhotosEvent {
  const _RabbitPhotosEmmitPhotosError(
    this.error,
  );

  final StorageExeption error;
}

/// This event emmits the default photo.
final class _RabbitPhotosEmmitDefaultPhoto extends RabbitPhotosEvent {
  const _RabbitPhotosEmmitDefaultPhoto(
    this.photo,
  );

  final Photo photo;

  @override
  List<Object> get props => [photo];
}

/// This event initiates the loading of the default photo from the storage.
final class RabbitPhotosGetDefaultPhoto extends RabbitPhotosEvent {
  const RabbitPhotosGetDefaultPhoto();
}

/// This event sets the photo with the given [photoId] as the default photo for the rabbit.
final class RabbitPhotosSetDefaultPhoto extends RabbitPhotosEvent {
  const RabbitPhotosSetDefaultPhoto(this.photoId);

  final String photoId;

  @override
  List<Object> get props => [photoId];
}

/// This event deletes the photo with the given [photoId].
final class RabbitPhotosDeletePhoto extends RabbitPhotosEvent {
  const RabbitPhotosDeletePhoto(this.photoId);

  final String photoId;

  @override
  List<Object> get props => [photoId];
}

/// This event adds a new photo to the storage.
final class RabbitPhotosAddPhoto extends RabbitPhotosEvent {
  const RabbitPhotosAddPhoto(this.name, this.data);

  final String name;
  final Uint8List data;

  @override
  List<Object> get props => [name, data];
}
