import 'package:firebase_auth/firebase_auth.dart';

import 'package:spk_app_frontend/features/auth/current_user.model.dart';
import 'package:spk_app_frontend/features/auth/roles.enum.dart';

class AuthService {
  AuthService();

  final FirebaseAuth _auth = FirebaseAuth.instance;

  Stream<CurrentUser> get user {
    return _auth.idTokenChanges().asyncMap((firebaseUser) async {
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

  Future<void> changePassword(String oldPassword, String newPassword) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('User is null');
    }

    try {
      await user.reauthenticateWithCredential(
        EmailAuthProvider.credential(email: user.email!, password: oldPassword),
      );
      await user.updatePassword(newPassword);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'wrong-password' || e.code == 'weak-password') {
        throw ChangePasswordException(e.code);
      }
      rethrow;
    }
  }

  Future<void> sendVerificationMail() async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('User is null');
    }

    // TODO: Add actonCodeSettings
    await user.sendEmailVerification();
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
      emailVerified: emailVerified,
      teamId: claims['teamId'],
      roles: claims['roles'] != null
          ? (claims['roles'] as List)
              .map((role) => Role.fromJson(role))
              .toList()
          : [],
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

/// Exception thrown when changing password fails.
///
/// [code] types:
/// - 'wrong-password' - wrong old password
/// - 'weak-password' - weak new password
///
class ChangePasswordException implements Exception {
  ChangePasswordException(this.code);

  final String code;

  @override
  String toString() {
    return 'ChangePasswordFailure: $code';
  }
}
