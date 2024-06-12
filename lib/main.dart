import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:firebase_ui_oauth_google/firebase_ui_oauth_google.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart' show FirebaseAuth;
import 'package:hive_flutter/hive_flutter.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:path_provider/path_provider.dart';

import 'package:spk_app_frontend/app/app.dart';
import 'package:spk_app_frontend/config/config.dart';
import 'package:spk_app_frontend/config/firebase_options.dart';
import 'package:spk_app_frontend/features/rabbit_photos/models/models.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  HydratedBloc.storage = await HydratedStorage.build(
    storageDirectory: kIsWeb
        ? HydratedStorage.webStorageDirectory
        : await getApplicationDocumentsDirectory(),
  );

  await _initHive();

  if (kDebugMode) {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: 'fake',
        appId: 'fake',
        messagingSenderId: 'fake',
        projectId: AppConfig.firebaseEmulatorsProjectId,
      ),
    );
    await FirebaseAuth.instance.useAuthEmulator(
      AppConfig.firebaseAuthEmulatorHost,
      AppConfig.firebaseAuthEmulatorPort,
    );
    print(
        'Running in debug mode with Firebase Emulators. Make sure emulators are running.');
  } else {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }

  FirebaseUIAuth.configureProviders([
    EmailAuthProvider(),
    GoogleProvider(clientId: AppConfig.googleClientId),
  ]);

  runApp(const MyApp());
}

Future<void> _initHive() async {
  if (!kIsWeb) {
    final appDir = await getApplicationCacheDirectory();
    Hive.init(
      appDir.path,
    );
  }
  Hive.registerAdapter(PhotoAdapter());
}
