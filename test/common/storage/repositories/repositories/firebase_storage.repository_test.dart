import 'package:clock/clock.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:spk_app_frontend/common/storage/errors/errors.dart';

import 'package:spk_app_frontend/common/storage/repositories/repositories/firebase_storage.repository.dart';

class MockFirebaseApp extends Mock implements FirebaseApp {}

class MockFirebaseStorage extends Mock implements FirebaseStorage {}

class MockFirebaseAuth extends Mock implements FirebaseAuth {}

class MockUserCredential extends Mock implements UserCredential {}

class MockUser extends Mock implements User {}

class MockIdTokenResult extends Mock implements IdTokenResult {}

class TestFirebaseStorageRepository extends FirebaseStorageRepository {
  TestFirebaseStorageRepository({
    required super.firebaseAuth,
    required super.firebaseStorage,
  });
}

void main() {
  group(FirebaseStorageRepository, () {
    late FirebaseApp firebaseApp;
    late FirebaseStorage firebaseStorage;
    late FirebaseAuth firebaseAuth;
    late FirebaseStorageRepository firebaseStorageRepository;

    setUp(() {
      firebaseApp = MockFirebaseApp();
      firebaseStorage = MockFirebaseStorage();
      firebaseAuth = MockFirebaseAuth();
      when(() => firebaseStorage.app).thenReturn(firebaseApp);
      when(() => firebaseAuth.app).thenReturn(firebaseApp);

      firebaseStorageRepository = TestFirebaseStorageRepository(
        firebaseAuth: firebaseAuth,
        firebaseStorage: firebaseStorage,
      );
    });

    group('close', () {
      test('Test close method', () async {
        when(() => firebaseApp.delete()).thenAnswer((_) async {});
        await firebaseStorageRepository.close();
        verify(() => firebaseApp.delete()).called(1);
      });
    });

    group('setToken', () {
      test('should set token', () async {
        const token = 'fake_token';
        when(() => firebaseAuth.signInWithCustomToken(token))
            .thenAnswer((_) async => MockUserCredential());
        await firebaseStorageRepository.setToken(token);
        verify(() => firebaseAuth.signInWithCustomToken(token)).called(1);
      });

      test('should throws StorageTokenNotSetExeption', () async {
        const token = 'fake_token';
        when(() => firebaseAuth.signInWithCustomToken(token))
            .thenThrow(FirebaseAuthException(code: 'fake_code'));

        expect(firebaseStorageRepository.setToken(token),
            throwsA(isA<StorageTokenNotSetExeption>()));
      });

      test('should throws StorageUnknownExeption', () async {
        const token = 'fake_token';
        when(() => firebaseAuth.signInWithCustomToken(token))
            .thenThrow(Exception());

        expect(firebaseStorageRepository.setToken(token),
            throwsA(isA<StorageUnknownExeption>()));
      });
    });

    group('parseFirebaseException', () {
      final currentTime = DateTime(2024, 4, 1, 12);
      withClock(Clock.fixed(currentTime), () async {
        test('should return StorageTokenNotSetExeption', () async {
          final exception = FirebaseException(
              plugin: 'storage', code: 'storage/unauthenticated');
          final result =
              // ignore: invalid_use_of_protected_member
              await firebaseStorageRepository.parseFirebaseException(exception);
          expect(result, isA<StorageTokenNotSetExeption>());
        });

        test('should return StorageTokenExpiredExeption', () async {
          final exception = FirebaseException(
              plugin: 'storage', code: 'storage/unauthorized');
          final user = MockUser();
          final tokenResult = MockIdTokenResult();
          when(() => firebaseAuth.currentUser).thenReturn(user);
          when(() => user.getIdTokenResult())
              .thenAnswer((_) async => tokenResult);
          when(() => tokenResult.claims).thenReturn(
              {'expiresAt': clock.minutesAgo(1).millisecondsSinceEpoch});

          final result =
              // ignore: invalid_use_of_protected_member
              await firebaseStorageRepository.parseFirebaseException(exception);
          expect(result, isA<StorageTokenExpiredExeption>());
        });

        test(
          'should return StorageUnauthorizedExeption',
          () async {
            final exception = FirebaseException(
                plugin: 'storage', code: 'storage/unauthorized');
            final user = MockUser();
            final tokenResult = MockIdTokenResult();
            when(() => firebaseAuth.currentUser).thenReturn(user);
            when(() => user.getIdTokenResult())
                .thenAnswer((_) async => tokenResult);
            when(() => tokenResult.claims).thenReturn(
                {'expiresAt': clock.minutesFromNow(10).millisecondsSinceEpoch});

            final result = await firebaseStorageRepository
                // ignore: invalid_use_of_protected_member
                .parseFirebaseException(exception);
            expect(result, isA<StorageUnauthorizedExeption>());
          },
        );

        test('should return StorageTokenNotSetExeption', () async {
          final exception = FirebaseException(
              plugin: 'storage', code: 'storage/unauthorized');
          when(() => firebaseAuth.currentUser).thenReturn(null);

          final result =
              // ignore: invalid_use_of_protected_member
              await firebaseStorageRepository.parseFirebaseException(exception);
          expect(result, isA<StorageTokenNotSetExeption>());
        });

        test('should return StorageUnknownExeption', () async {
          final exception =
              FirebaseException(plugin: 'storage', code: 'fake_code');
          final result =
              // ignore: invalid_use_of_protected_member
              await firebaseStorageRepository.parseFirebaseException(exception);
          expect(result, isA<StorageUnknownExeption>());
        });
      });
    });
  });
}
