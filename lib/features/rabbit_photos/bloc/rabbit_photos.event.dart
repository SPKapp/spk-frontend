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

final class _RabbitPhotosEmmitPhotos extends RabbitPhotosEvent {
  const _RabbitPhotosEmmitPhotos();
}

/// This event initiates the loading of the default photo from the storage.
final class RabbitPhotosGetDefaultPhoto extends RabbitPhotosEvent {
  const RabbitPhotosGetDefaultPhoto();
}
