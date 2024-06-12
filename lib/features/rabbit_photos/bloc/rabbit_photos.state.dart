part of 'rabbit_photos.bloc.dart';

sealed class RabbitPhotosState extends Equatable {
  const RabbitPhotosState();

  @override
  List<Object> get props => [];
}

final class RabbitPhotosInitial extends RabbitPhotosState {}

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
