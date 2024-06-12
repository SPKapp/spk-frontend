part of 'rabbit_photos.bloc.dart';

sealed class RabbitPhotosState extends Equatable {
  const RabbitPhotosState();

  @override
  List<Object> get props => [];
}

/// Initial state of the [RabbitPhotosBloc].
final class RabbitPhotosInitial extends RabbitPhotosState {}

/// This state is emitted when the some of the photos are loaded.
/// The [names] are the names of the photos and the [photos] contains map of the names and the [Photo] objects.
/// If the name is not in the [photos] map, the photo is not loaded.
/// If in the [photos] map object is [Photo.error], error occured while loading the photo.
final class RabbitPhotosList extends RabbitPhotosState {
  RabbitPhotosList({
    required List<String> names,
    required Map<String, Photo> photos,
  })  : names = List<String>.from(names),
        photos = Map<String, Photo>.from(photos);

  final List<String> names;
  final Map<String, Photo> photos;

  @override
  List<Object> get props => [names, photos];
}

/// This state is emitted when an error occurs and any of the photos cannot be loaded.
/// The [code] is the error code.
final class RabbitPhotosFailure extends RabbitPhotosState {
  const RabbitPhotosFailure({
    required this.code,
  });

  final StorageExeption code;

  @override
  List<Object> get props => [code];
}
