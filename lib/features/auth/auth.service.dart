import 'package:firebase_auth/firebase_auth.dart';

import 'package:spk_app_frontend/features/auth/current_user.model.dart';

// TODO: Add Cache
// TODO: Ustaw role użytkownika
class AuthService {
  AuthService();

  final FirebaseAuth _auth = FirebaseAuth.instance;

  Stream<CurrentUser> get user {
    return _auth.authStateChanges().map((firebaseUser) {
      final currentUser =
          firebaseUser == null ? CurrentUser.empty : firebaseUser.toCurrentUser;
      return currentUser;
    });
  }

  CurrentUser get currentUser {
    return _auth.currentUser?.toCurrentUser ?? CurrentUser.empty;
  }

  Future<void> logout() async {
    try {
      await _auth.signOut();
    } catch (e) {
      throw LogoutFailure();
    }
  }
}

extension on User {
  CurrentUser get toCurrentUser {
    return CurrentUser(
      uid: uid,
      email: email,
      phone: phoneNumber,
      name: displayName,
    );
  }
}

class LogoutFailure implements Exception {}
