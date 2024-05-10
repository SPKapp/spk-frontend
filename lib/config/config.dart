abstract class AppConfig {
  static const String apiUrl = String.fromEnvironment('API_URL');
  static const String appName =
      String.fromEnvironment('APP_NAME', defaultValue: 'HopManager Dev');
  static const String photoUrl = String.fromEnvironment('PHOTO_URL');

  static const String firebaseEmulatorsProjectId =
      String.fromEnvironment('FIREBASE_EMULATORS_PROJECT_ID');
  static const String firebaseAuthEmulatorHost =
      String.fromEnvironment('FIREBASE_AUTH_EMULATOR_HOST');
  static const int firebaseAuthEmulatorPort =
      int.fromEnvironment('FIREBASE_AUTH_EMULATOR_PORT');
}
