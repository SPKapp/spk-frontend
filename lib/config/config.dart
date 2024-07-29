abstract class AppConfig {
  static const String apiUrl = String.fromEnvironment('API_URL');
  static const String appName =
      String.fromEnvironment('APP_NAME', defaultValue: 'HopManager Dev');

  // Firebase Emulator settings
  static const String firebaseEmulatorsProjectId =
      String.fromEnvironment('FIREBASE_EMULATORS_PROJECT_ID');
  static const String firebaseAuthEmulatorHost =
      String.fromEnvironment('FIREBASE_AUTH_EMULATOR_HOST');
  static const int firebaseAuthEmulatorPort =
      int.fromEnvironment('FIREBASE_AUTH_EMULATOR_PORT');
  static const String firebaseStorageEmulatorHost =
      String.fromEnvironment('FIREBASE_STORAGE_EMULATOR_HOST');
  static const int firebaseStorageEmulatorPort =
      int.fromEnvironment('FIREBASE_STORAGE_EMULATOR_PORT');
  static const String firebaseStorageBucketEmulator =
      String.fromEnvironment('FIREBASE_STORAGE_BUCKET_EMULATOR');

  // Google OAuth Client ID
  static const String googleClientId =
      String.fromEnvironment('GOOGLE_CLIENT_ID');

  static const String webVapidKey = String.fromEnvironment('WEB_VAPID_KEY');
}
