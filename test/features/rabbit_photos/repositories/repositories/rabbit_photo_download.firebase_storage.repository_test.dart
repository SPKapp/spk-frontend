import 'dart:typed_data';

import 'package:clock/clock.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:mocktail/mocktail.dart';
import 'package:spk_app_frontend/common/storage/storage.dart';
import 'package:spk_app_frontend/features/rabbit_photos/models/models.dart';
import 'package:spk_app_frontend/features/rabbit_photos/repositories/repositories/rabbit_photo_download.firebase_storage.repository.dart';

class MockBox extends Mock implements Box<Photo> {}

class MockFirebaseApp extends Mock implements FirebaseApp {}

class MockFirebaseStorage extends Mock implements FirebaseStorage {}

class MockFirebaseAuth extends Mock implements FirebaseAuth {}

class MockUserCredential extends Mock implements UserCredential {}

class MockUser extends Mock implements User {}

class MockIdTokenResult extends Mock implements IdTokenResult {}

class MockReference extends Mock implements Reference {}

class MockListResult extends Mock implements ListResult {}

class MockMetadata extends Mock implements FullMetadata {}

void main() async {
  group(RabbitPhotosFirebaseStorageRepositroy, () {
    const rabbitId = '123';
    const path = 'rabbits/$rabbitId/photos/';
    late Box<Photo> box;
    late FirebaseApp firebaseApp;
    late FirebaseStorage firebaseStorage;
    late FirebaseAuth firebaseAuth;
    late Reference storageRef;
    late RabbitPhotosFirebaseStorageRepositroy repository;

    setUpAll(() {
      registerFallbackValue(Photo.error());
    });

    setUp(() async {
      box = MockBox();
      firebaseApp = MockFirebaseApp();
      firebaseStorage = MockFirebaseStorage();
      firebaseAuth = MockFirebaseAuth();
      storageRef = MockReference();

      when(() => firebaseStorage.ref(any())).thenReturn(storageRef);
      when(() => firebaseStorage.app).thenReturn(firebaseApp);
      when(() => firebaseAuth.app).thenReturn(firebaseApp);

      repository = RabbitPhotosFirebaseStorageRepositroy(
        rabbitId: rabbitId,
        box: box,
        firebaseStorage: firebaseStorage,
        firebaseAuth: firebaseAuth,
      );

      await repository.init();
    });

    group('close', () {
      test('should close repository', () async {
        when(() => firebaseApp.delete()).thenAnswer((_) async {});
        await repository.close();

        verify(() => firebaseApp.delete()).called(1);
      });
    });

    group('listPhotos', () {
      test('should list photos and delete old photos from cache', () async {
        final results = [
          MockReference(),
          MockReference(),
        ];
        final listResult = MockListResult();
        when(() => listResult.items).thenReturn(results);
        when(() => storageRef.listAll()).thenAnswer((_) async => listResult);
        when(() => results[0].fullPath).thenReturn('path/to/photo.jpg');
        when(() => results[0].name).thenReturn('photo.jpg');
        when(() => results[1].fullPath).thenReturn('path/to/photo2.jpg');
        when(() => results[1].name).thenReturn('photo2.jpg');

        when(() => box.keys)
            .thenReturn(['rabbits/$rabbitId/photos/oldPhoto.jpg']);
        when(() => box.delete(any())).thenAnswer((_) async {});

        final result = await repository.listPhotos();
        expect(result, ['photo.jpg', 'photo2.jpg']);

        verify(() => storageRef.listAll()).called(1);
        verify(() => box.delete('rabbits/$rabbitId/photos/oldPhoto.jpg'))
            .called(1);
      });

      test('should throw an exception when listing photos', () async {
        when(() => storageRef.listAll()).thenThrow(Exception());

        expect(repository.listPhotos(), throwsA(isA<StorageUnknownExeption>()));
      });
    });

    group('getPhoto', () {
      test('should download photo if it does not exist in cache', () async {
        const photoId = 'photoId';
        final photo = Photo(
          data: Uint8List.fromList([0]),
          updatedAt: DateTime(2024, 4, 1),
        );
        final metadata = MockMetadata();

        when(() => box.get(any())).thenReturn(null);
        when(() => storageRef.child(photoId)).thenReturn(storageRef);
        when(() => storageRef.getMetadata()).thenAnswer((_) async => metadata);
        when(() => storageRef.getData()).thenAnswer((_) async => photo.data);
        when(() => metadata.updated).thenReturn(photo.updatedAt);
        when(() => box.put(any(), any())).thenAnswer((_) async {});

        repository.getPhoto(photoId);
        await expectLater(
            repository.photosStream, emitsInOrder([(photoId, photo)]));

        verify(() => storageRef.child(photoId)).called(1);
        verify(() => storageRef.getMetadata()).called(1);
        verify(() => storageRef.getData()).called(1);
        verify(() => box.put('$path$photoId', photo)).called(1);
      });

      test('should get photo from cache', () async {
        const photoId = 'photoId';
        final photo = Photo(
          data: Uint8List.fromList([0]),
          updatedAt: DateTime(2024, 4, 1),
        );
        final metadata = MockMetadata();

        when(() => box.get(any())).thenReturn(photo);
        when(() => storageRef.child(photoId)).thenReturn(storageRef);
        when(() => storageRef.getMetadata()).thenAnswer((_) async => metadata);
        when(() => metadata.updated).thenReturn(photo.updatedAt);

        repository.getPhoto(photoId);

        await expectLater(
            repository.photosStream, emitsInOrder([(photoId, photo)]));

        verify(() => storageRef.child(photoId)).called(1);
        verify(() => storageRef.getMetadata()).called(1);
      });

      test('should download photo if in cache is not actual version', () async {
        const photoId = 'photoId';
        final oldPhoto = Photo(
          data: Uint8List.fromList([0]),
          updatedAt: DateTime(2024, 4, 1),
        );
        final newPhoto = Photo(
          data: Uint8List.fromList([0]),
          updatedAt: DateTime(2024, 4, 2),
        );
        final metadata = MockMetadata();

        when(() => box.get(any())).thenReturn(oldPhoto);
        when(() => storageRef.child(photoId)).thenReturn(storageRef);
        when(() => storageRef.getMetadata()).thenAnswer((_) async => metadata);
        when(() => storageRef.getData()).thenAnswer((_) async => newPhoto.data);
        when(() => metadata.updated).thenReturn(newPhoto.updatedAt);
        when(() => box.delete(any())).thenAnswer((_) async {});
        when(() => box.put(any(), any())).thenAnswer((_) async {});

        repository.getPhoto(photoId);
        await expectLater(
            repository.photosStream, emitsInOrder([(photoId, newPhoto)]));

        verify(() => storageRef.child(photoId)).called(2);
        verify(() => storageRef.getMetadata()).called(2);
        verify(() => box.delete(any())).called(1);
        verify(() => storageRef.getData()).called(1);
        verify(() => box.put('$path$photoId', newPhoto)).called(1);
      });

      test('should throw an exception when getting photo', () {
        final currentTime = DateTime(2024, 4, 1, 12);
        withClock(Clock.fixed(currentTime), () async {
          final exception = FirebaseException(
              plugin: 'storage', code: 'storage/unauthorized');
          final user = MockUser();
          final tokenResult = MockIdTokenResult();
          when(() => firebaseAuth.currentUser).thenReturn(user);
          when(() => user.getIdTokenResult())
              .thenAnswer((_) async => tokenResult);
          when(() => tokenResult.claims).thenReturn(
              {'expiresAt': clock.minutesAgo(1).millisecondsSinceEpoch});

          const token = 'fake_token';
          const photoId = 'photoId';
          final photo = Photo(
            data: Uint8List.fromList([0]),
            updatedAt: DateTime(2024, 4, 1),
          );
          final metadata = MockMetadata();

          when(() => box.get(any())).thenReturn(null);
          when(() => storageRef.child(photoId)).thenReturn(storageRef);
          when(() => storageRef.getMetadata()).thenThrow(exception);

          repository.getPhoto(photoId);

          await expectLater(repository.photosStream,
              emitsError(isA<StorageTokenExpiredExeption>()));

          when(() => firebaseAuth.signInWithCustomToken(token))
              .thenAnswer((_) async => MockUserCredential());
          when(() => storageRef.getMetadata())
              .thenAnswer((_) async => metadata);
          when(() => storageRef.getData()).thenAnswer((_) async => photo.data);
          when(() => metadata.updated).thenReturn(photo.updatedAt);
          when(() => box.put(any(), any())).thenAnswer((_) async {});

          await repository.setToken(token);

          await expectLater(
              repository.photosStream, emitsInOrder([(photoId, photo)]));
        });
      });
    });
  });
}
