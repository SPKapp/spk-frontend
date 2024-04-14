import 'package:firebase_auth/firebase_auth.dart';

import 'package:spk_app_frontend/features/auth/current_user.model.dart';
import 'package:spk_app_frontend/features/auth/roles.enum.dart';

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
    final tokenResult = await getIdTokenResult();

    final token = tokenResult.token;
    if (token == null) {
      throw Exception('Token is null');
    }

    final claims = tokenResult.claims;
    if (claims == null) {
      throw Exception('Claims are null');
    }

    return CurrentUser(
      uid: uid,
      token: token,
      email: email,
      phone: phoneNumber,
      name: displayName,
      // roles: [Role.regionRabbitObserver],
      // teamId: 2,
      roles:
          (claims['roles'] as List).map((role) => Role.fromJson(role)).toList(),
    );
  }
}

class LogoutFailure implements Exception {}
