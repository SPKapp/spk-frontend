import 'package:clock/clock.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import 'package:spk_app_frontend/common/services/logger.service.dart';
import 'package:spk_app_frontend/common/storage/errors/errors.dart';
import 'package:spk_app_frontend/common/storage/repositories/interfaces/storage.repo.interface.dart';
import 'package:spk_app_frontend/config/config.dart';
import 'package:spk_app_frontend/config/firebase_options.dart';

/// {@macro storage_repository}
abstract class FirebaseStorageRepository implements IStorageRepository {
  /// {@macro storage_repository}
  FirebaseStorageRepository(
      {@visibleForTesting FirebaseStorage? firebaseStorage,
      @visibleForTesting FirebaseAuth? firebaseAuth})
      : assert(
            (firebaseStorage == null && firebaseAuth == null) ||
                (firebaseStorage != null &&
                    firebaseAuth != null &&
                    firebaseAuth.app == firebaseStorage.app),
            'firebaseStorage and firebaseAuth must be both null or both not null.') {
    if (firebaseStorage != null) {
      _firebaseStorage = firebaseStorage;
      _firebaseAuth = firebaseAuth!;
      _app = firebaseStorage.app;
    }
  }

  @protected
  FirebaseStorage get firebaseStorage => _firebaseStorage!;

  FirebaseStorage? _firebaseStorage;
  FirebaseAuth? _firebaseAuth;
  FirebaseApp? _app;

  @protected
  final logger = LoggerService();

  /// {@macro storage_repository.init}
  @override
  @mustCallSuper
  Future<void> init() async {
    if (_app == null) {
      final name = const Uuid().v4();
      if (kDebugMode) {
        _app = await Firebase.initializeApp(
          name: name,
          options: const FirebaseOptions(
            apiKey: 'fake',
            appId: 'fake',
            messagingSenderId: 'fake',
            storageBucket: AppConfig.firebaseStorageBucketEmulator,
            projectId: AppConfig.firebaseEmulatorsProjectId,
          ),
        );
        await FirebaseStorage.instanceFor(app: _app).useStorageEmulator(
          AppConfig.firebaseStorageEmulatorHost,
          AppConfig.firebaseStorageEmulatorPort,
        );
      } else {
        _app = await Firebase.initializeApp(
          name: name,
          options: DefaultFirebaseOptions.currentPlatform,
        );
      }
      _firebaseStorage = FirebaseStorage.instanceFor(app: _app);
      _firebaseAuth = FirebaseAuth.instanceFor(app: _app!);
    }
  }

  /// {@macro storage_repository.dispose}
  @override
  @mustCallSuper
  Future<void> close() async {
    await _app!.delete();
  }

  /// {@macro storage_repository.setToken}
  @override
  @mustCallSuper
  Future<void> setToken(String token) async {
    try {
      await _firebaseAuth!.signInWithCustomToken(token);
    } on FirebaseAuthException catch (e) {
      logger.error('Cannot set token', error: e);
      throw const StorageTokenNotSetExeption();
    } catch (e) {
      // This should not happen
      logger.error('Cannot set token', error: e);
      throw const StorageUnknownExeption();
    }
  }

  /// {@macro storage_repository.getUserId}
  @override
  @nonVirtual
  String getUserId() {
    final user = _firebaseAuth!.currentUser;
    if (user == null) {
      throw const StorageTokenNotSetExeption();
    }
    return user.uid;
  }

  /// This method parses the Firebase exception to the [StorageExeption].
  @nonVirtual
  @protected
  Future<StorageExeption> parseFirebaseException(FirebaseException e) async {
    if (e.code == 'storage/unauthenticated') {
      return const StorageTokenNotSetExeption();
    } else if (e.code == 'storage/unauthorized') {
      // Check reason - token expired or user unauthorized
      final token = await _firebaseAuth!.currentUser?.getIdTokenResult();
      if (token != null) {
        final expiresAt = token.claims?['expiresAt'];
        if (expiresAt != null) {
          final expiresAtDateTime = DateTime.fromMillisecondsSinceEpoch(
            expiresAt as int,
          );
          if (clock.now().isAfter(expiresAtDateTime)) {
            return const StorageTokenExpiredExeption();
          } else {
            return const StorageUnauthorizedExeption();
          }
        }
      }
      // That should not happen
      return const StorageTokenNotSetExeption();
    } else if (e.code == 'object-not-found') {
      return const StorageFileNotFoundExeption(fileId: null);
    } else {
      logger.error('Unknown Firebase Storage error', error: e);
      return const StorageUnknownExeption();
    }
  }
}
