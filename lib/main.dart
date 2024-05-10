import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart' show FirebaseAuth;

import 'package:spk_app_frontend/app/app.dart';
import 'package:spk_app_frontend/config/config.dart';
import 'package:spk_app_frontend/config/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

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
        AppConfig.firebaseAuthEmulatorHost, AppConfig.firebaseAuthEmulatorPort);
  } else {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }

  FirebaseUIAuth.configureProviders([EmailAuthProvider()]);

  runApp(const MyApp());
}
