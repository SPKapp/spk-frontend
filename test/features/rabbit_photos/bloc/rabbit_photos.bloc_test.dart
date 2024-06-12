import 'dart:async';
import 'dart:typed_data';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:spk_app_frontend/common/storage/storage.dart';
import 'package:spk_app_frontend/features/rabbit_photos/bloc/rabbit_photos.bloc.dart';
import 'package:spk_app_frontend/features/rabbit_photos/models/models.dart';
import 'package:spk_app_frontend/features/rabbit_photos/repositories/interfaces.dart';

class MockStorageAuthRepository extends Mock
    implements IStorageAuthRepository {}

class MockRabbitPhotoDownloadRepository extends Mock
    implements IRabbitPhotoDownloadRepository {}

void main() {
  group(RabbitPhotosBloc, () {
    const rabbitId = '1';
    const token = 'token';
    late RabbitPhotosBloc rabbitPhotosBloc;
    late IStorageAuthRepository storageAuthRepository;
    late IRabbitPhotoDownloadRepository photosRepositroy;
    late StreamController<(String, Photo)> photosStreamController;

    setUp(() {
      storageAuthRepository = MockStorageAuthRepository();
      photosRepositroy = MockRabbitPhotoDownloadRepository();
      photosStreamController = StreamController<(String, Photo)>.broadcast();
      when(() => photosRepositroy.init()).thenAnswer((_) async {});
      when(() => photosRepositroy.close()).thenAnswer((_) async {});
      when(() => photosRepositroy.photosStream)
          .thenAnswer((_) => photosStreamController.stream);
      when(() => storageAuthRepository.getTokenForRabbitPhotos(rabbitId))
          .thenAnswer((_) async => token);
      when(() => photosRepositroy.setToken(any())).thenAnswer((_) async {});

      rabbitPhotosBloc = RabbitPhotosBloc(
        rabbitId: rabbitId,
        storageAuthRepository: storageAuthRepository,
        photosRepositroy: photosRepositroy,
      );
    });

    tearDown(() {
      rabbitPhotosBloc.close();
    });

    test('initial state is RabbitPhotosInitial', () {
      expect(rabbitPhotosBloc.state, RabbitPhotosInitial());
    });

    test('close does not emit new states', () {
      expectLater(
        rabbitPhotosBloc.stream,
        emitsInOrder(<dynamic>[emitsDone]),
      );
      rabbitPhotosBloc.close();
    });

    test('init initializes the repository and subscribes to the stream',
        () async {
      verify(() => photosRepositroy.init()).called(1);
      verify(() => photosRepositroy.photosStream).called(1);
    });

    group('RabbitPhotosLoadPhotos', () {
      blocTest<RabbitPhotosBloc, RabbitPhotosState>(
        'emits RabbitPhotosList when no auth token is set',
        setUp: () {
          when(() => photosRepositroy.listPhotos())
              .thenAnswer((_) async => ['1', '2']);
          when(() => photosRepositroy.getPhotos(any())).thenAnswer((_) {});
        },
        build: () => rabbitPhotosBloc,
        act: (bloc) => bloc.add(const RabbitPhotosLoadPhotos()),
        expect: () => [
          RabbitPhotosList(names: const ['1', '2'], photos: const {}),
        ],
        verify: (_) {
          verify(() => storageAuthRepository.getTokenForRabbitPhotos(rabbitId))
              .called(1);
          verify(() => photosRepositroy.setToken(token)).called(1);
          verify(() => photosRepositroy.listPhotos()).called(1);
          verify(() => photosRepositroy.getPhotos(['1', '2'])).called(1);
        },
      );

      blocTest<RabbitPhotosBloc, RabbitPhotosState>(
        'emits RabbitPhotosList when auth token is set',
        setUp: () {
          rabbitPhotosBloc.authenticate();
          when(() => photosRepositroy.listPhotos())
              .thenAnswer((_) async => ['1', '2']);
          when(() => photosRepositroy.getPhotos(any())).thenAnswer((_) {});
        },
        build: () => rabbitPhotosBloc,
        act: (bloc) => bloc.add(const RabbitPhotosLoadPhotos()),
        expect: () => [
          RabbitPhotosList(names: const ['1', '2'], photos: const {}),
        ],
        verify: (_) {
          verify(() => storageAuthRepository.getTokenForRabbitPhotos(rabbitId))
              .called(1);
          verify(() => photosRepositroy.setToken(token));
          verify(() => photosRepositroy.listPhotos()).called(1);
          verify(() => photosRepositroy.getPhotos(['1', '2'])).called(1);
        },
      );

      blocTest<RabbitPhotosBloc, RabbitPhotosState>(
        'emits RabbitPhotosList when auth token is expired',
        setUp: () {
          int numberOfCalls = 0;
          rabbitPhotosBloc.authenticate();
          when(() => photosRepositroy.listPhotos()).thenAnswer((_) async {
            if (numberOfCalls == 0) {
              numberOfCalls++;
              throw const StorageTokenExpiredExeption();
            }
            return ['1', '2'];
          });
          when(() => photosRepositroy.getPhotos(any())).thenAnswer((_) {});
        },
        build: () => rabbitPhotosBloc,
        act: (bloc) => bloc.add(const RabbitPhotosLoadPhotos()),
        expect: () => [
          RabbitPhotosList(names: const ['1', '2'], photos: const {}),
        ],
        verify: (_) {
          verify(() => storageAuthRepository.getTokenForRabbitPhotos(rabbitId))
              .called(2);
          verify(() => photosRepositroy.setToken(token)).called(2);

          verify(() => photosRepositroy.listPhotos()).called(2);
          verify(() => photosRepositroy.getPhotos(['1', '2'])).called(1);
        },
      );

      blocTest<RabbitPhotosBloc, RabbitPhotosState>(
        'emits RabbitPhotosError when an error occurs',
        setUp: () {
          rabbitPhotosBloc.authenticate();
          when(() => photosRepositroy.listPhotos())
              .thenThrow(const StorageUnauthorizedExeption());
        },
        build: () => rabbitPhotosBloc,
        act: (bloc) => bloc.add(const RabbitPhotosLoadPhotos()),
        expect: () => [
          const RabbitPhotosFailure(code: const StorageUnauthorizedExeption()),
        ],
        verify: (_) {
          verify(() => photosRepositroy.listPhotos()).called(1);
          verifyNever(() => photosRepositroy.getPhotos(any()));
        },
      );

      blocTest<RabbitPhotosBloc, RabbitPhotosState>(
        'emits RabbitPhotosError when an unknown error occurs',
        setUp: () {
          rabbitPhotosBloc.authenticate();
          when(() => photosRepositroy.listPhotos()).thenThrow(Exception());
        },
        build: () => rabbitPhotosBloc,
        act: (bloc) => bloc.add(const RabbitPhotosLoadPhotos()),
        expect: () => [
          const RabbitPhotosFailure(code: StorageUnknownExeption()),
        ],
        verify: (_) {
          verify(() => photosRepositroy.listPhotos()).called(1);
          verifyNever(() => photosRepositroy.getPhotos(any()));
        },
      );
    });

    group('emit RabbitPhotosList from stream', () {
      final photo = Photo(
        data: Uint8List(12),
        updatedAt: DateTime(2021),
      );

      blocTest<RabbitPhotosBloc, RabbitPhotosState>(
        'emits RabbitPhotosList when a photo is received',
        setUp: () async {
          rabbitPhotosBloc.authenticate();
          rabbitPhotosBloc.add(const RabbitPhotosLoadPhotos());
          when(() => photosRepositroy.listPhotos())
              .thenAnswer((_) async => ['1', '2']);
          when(() => photosRepositroy.getPhotos(any())).thenAnswer((_) {});
        },
        build: () => rabbitPhotosBloc,
        act: (bloc) async {
          await rabbitPhotosBloc.stream.first;
          photosStreamController.add(('1', photo));
        },
        expect: () => [
          RabbitPhotosList(names: const ['1', '2'], photos: const {}),
          RabbitPhotosList(names: const ['1', '2'], photos: {'1': photo}),
        ],
        verify: (_) {
          verify(() => photosRepositroy.listPhotos()).called(1);
          verify(() => photosRepositroy.getPhotos(['1', '2'])).called(1);
        },
      );

      blocTest<RabbitPhotosBloc, RabbitPhotosState>(
        'emits RabbitPhotosList when a error occurs',
        setUp: () async {
          rabbitPhotosBloc.authenticate();
          rabbitPhotosBloc.add(const RabbitPhotosLoadPhotos());
          when(() => photosRepositroy.listPhotos())
              .thenAnswer((_) async => ['1', '2']);
          when(() => photosRepositroy.getPhotos(any())).thenAnswer((_) {});
        },
        build: () => rabbitPhotosBloc,
        act: (bloc) async {
          await rabbitPhotosBloc.stream.first;
          photosStreamController
              .addError(const StorageUnknownExeption(fileId: '1'));
        },
        expect: () => [
          RabbitPhotosList(names: const ['1', '2'], photos: const {}),
          RabbitPhotosList(
            names: const ['1', '2'],
            photos: {'1': Photo.error()},
          ),
        ],
        verify: (_) {
          verify(() => photosRepositroy.listPhotos()).called(1);
          verify(() => photosRepositroy.getPhotos(['1', '2'])).called(1);
        },
      );

      blocTest<RabbitPhotosBloc, RabbitPhotosState>(
        'emits RabbitPhotosList when a photo is not found',
        setUp: () async {
          rabbitPhotosBloc.authenticate();
          rabbitPhotosBloc.add(const RabbitPhotosLoadPhotos());
          when(() => photosRepositroy.listPhotos())
              .thenAnswer((_) async => ['1', '2']);
          when(() => photosRepositroy.getPhotos(any())).thenAnswer((_) {});
        },
        build: () => rabbitPhotosBloc,
        act: (bloc) async {
          await rabbitPhotosBloc.stream.first;
          photosStreamController
              .addError(const StorageFileNotFoundExeption(fileId: '1'));
        },
        expect: () => [
          RabbitPhotosList(names: const ['1', '2'], photos: const {}),
          RabbitPhotosList(
            names: const ['1', '2'],
            photos: {'1': Photo.error()},
          ),
        ],
        verify: (_) {
          verify(() => photosRepositroy.listPhotos()).called(1);
          verify(() => photosRepositroy.getPhotos(['1', '2'])).called(1);
        },
      );

      blocTest<RabbitPhotosBloc, RabbitPhotosState>(
        'emits RabbitPhotosList when a token is expired',
        setUp: () async {
          rabbitPhotosBloc.authenticate();
          rabbitPhotosBloc.add(const RabbitPhotosLoadPhotos());
          when(() => photosRepositroy.listPhotos())
              .thenAnswer((_) async => ['1', '2']);
          when(() => photosRepositroy.getPhotos(any())).thenAnswer((_) {});
        },
        build: () => rabbitPhotosBloc,
        act: (bloc) async {
          await rabbitPhotosBloc.stream.first;
          photosStreamController.addError(const StorageTokenExpiredExeption());
        },
        expect: () => [
          RabbitPhotosList(names: const ['1', '2'], photos: const {}),
        ],
        verify: (_) {
          verify(() => storageAuthRepository.getTokenForRabbitPhotos(rabbitId))
              .called(2);
          verify(() => photosRepositroy.setToken(token)).called(2);
        },
      );
    });
  });
}
