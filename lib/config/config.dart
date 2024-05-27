abstract class AppConfig {
  static const String apiUrl = String.fromEnvironment('API_URL');
  static const String appName =
      String.fromEnvironment('APP_NAME', defaultValue: 'HopManager Dev');
  static const String photoUrl = String.fromEnvironment('PHOTO_URL');

  // Firebase Emulator settings
  static const String firebaseEmulatorsProjectId =
      String.fromEnvironment('FIREBASE_EMULATORS_PROJECT_ID');
  static const String firebaseAuthEmulatorHost =
      String.fromEnvironment('FIREBASE_AUTH_EMULATOR_HOST');
  static const int firebaseAuthEmulatorPort =
      int.fromEnvironment('FIREBASE_AUTH_EMULATOR_PORT');

  // Google OAuth Client ID
  static const String googleClientId =
      String.fromEnvironment('GOOGLE_CLIENT_ID');

  static const String webVapidKey = String.fromEnvironment('WEB_VAPID_KEY');
}
