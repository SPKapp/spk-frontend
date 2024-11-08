import 'dart:typed_data';

import 'package:spk_app_frontend/common/storage/storage.dart';
import 'package:spk_app_frontend/features/rabbit_photos/models/models.dart';

abstract class IRabbitPhotoDownloadRepository extends IStorageRepository {
  /// {@template rabbit_photos_repository.list_photos}
  /// This method returns the list of photo names for the rabbit.
  /// {@endtemplate}
  Future<List<String>> listPhotos();

  /// {@template rabbit_photos_repository.get_photos}
  /// This method enqueues the download of the photos with the given [photoIds] for the rabbit.
  ///
  /// The photos will be returned by the [photosStream].
  ///
  /// ### Warnings
  /// * The order of returning photos in the [photosStream] may not be the same as in the [photoIds] list, but the priority is kept.
  /// * New [get*] request has priority over the old one.
  /// * If the photo was requested before, but it's not returned yet, it will be returned only once.
  /// {@endtemplate}
  void getPhotos(List<String> photoIds);

  /// {@template rabbit_photos_repository.get_photo}
  /// This method enqueues the download of the photo with the given [photoId] for the rabbit.
  ///
  /// The photo will be returned by the [photosStream].
  ///
  /// ### Warnings
  /// * New [get*] request has priority over the old one.
  /// * If the photo was requested before, but it's not returned yet, it will be returned only once.
  /// {@endtemplate}
  void getPhoto(String photoId);

  /// {@template rabbit_photos_repository.get_default_photo_name}
  /// This method returns photoId of the default photo for the rabbit.
  /// {@endtemplate}
  Future<String?> getDefaultPhotoName();

  /// {@template rabbit_photos_repository.set_default_photo_name}
  /// This method sets the photo with the given [photoId] as the default photo for the rabbit.
  /// {@endtemplate}
  Future<void> setDefaultPhotoName(String photoId);

  /// {@template rabbit_photos_repository.delete_photo}
  /// This method deletes the photo with the given [photoId] for the rabbit.
  /// {@endtemplate}
  Future<void> deletePhoto(String photoId);

  /// {@template rabbit_photos_repository.add_photo}
  /// This method adds the photo with the given [photoId] for the rabbit.
  /// {@endtemplate}
  Future<void> addPhoto(String photoId, Uint8List data);

  /// {@template rabbit_photos_repository.photosStream}
  /// This stream is used to return the photos, requested by the [getPhotos] and [getPhoto] methods.
  /// {@endtemplate}
  Stream<(String, Photo)> get photosStream;
}
