import 'package:firebase_auth/firebase_auth.dart';

abstract class AuthConfig {
  static final ActionCodeSettings actionCodeSettings = ActionCodeSettings(
    url: const String.fromEnvironment('AUTH_REDIRECT_URL'),
    // handleCodeInApp: true,
    // iOSBundleId: const String.fromEnvironment('IOS_BUNDLE_ID'),
    // androidPackageName: const String.fromEnvironment('ANDROID_PACKAGE_NAME'),
    // androidInstallApp: true,
    // androidMinimumVersion: const String.fromEnvironment('ANDROID_MINIMUM_VERSION'),
  );
}
