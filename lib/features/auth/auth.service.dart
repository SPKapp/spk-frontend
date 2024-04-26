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
      id: claims['userId'],
      uid: uid,
      token: token,
      email: email,
      phone: phoneNumber,
      name: displayName,
      teamId: claims['teamId'],
      roles:
          (claims['roles'] as List).map((role) => Role.fromJson(role)).toList(),
      managerRegions: claims['managerRegions'] != null
          ? (claims['managerRegions'] as List).map((e) => e as int).toList()
          : null,
      observerRegions: claims['observerRegions'] != null
          ? (claims['observerRegions'] as List).map((e) => e as int).toList()
          : null,
    );
  }
}

class LogoutFailure implements Exception {}
