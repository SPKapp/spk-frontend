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

/// This event initiates the loading of the default photo from the storage.
final class RabbitPhotosGetDefaultPhoto extends RabbitPhotosEvent {
  const RabbitPhotosGetDefaultPhoto();
}
