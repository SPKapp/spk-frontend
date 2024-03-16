import 'package:firebase_auth/firebase_auth.dart';

import 'package:spk_app_frontend/features/auth/current_user.model.dart';

// TODO: Ustaw role użytkownika
class AuthService {
  AuthService();

  final FirebaseAuth _auth = FirebaseAuth.instance;

  Stream<CurrentUser> get user {
    return _auth.authStateChanges().asyncMap((firebaseUser) async {
      return firebaseUser == null
          ? CurrentUser.empty
          : await firebaseUser.toCurrentUser;
    });
  }

  Future<CurrentUser> get currentUser async {
    return await _auth.currentUser?.toCurrentUser ?? CurrentUser.empty;
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
  Future<CurrentUser> get toCurrentUser async {
    final token = await getIdToken();
    if (token == null) {
      throw Exception('Token is null');
    }

    return CurrentUser(
      uid: uid,
      token: token,
      email: email,
      phone: phoneNumber,
      name: displayName,
    );
  }
}

class LogoutFailure implements Exception {}
