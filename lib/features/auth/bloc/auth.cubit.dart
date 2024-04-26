import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import 'package:spk_app_frontend/features/auth/auth.service.dart';
import 'package:spk_app_frontend/features/auth/current_user.model.dart';

part 'auth.state.dart';

/// A Cubit that manages the authentication state.
///
/// Available properties:
/// - [currentUser] - the current user if authenticated, [CurrentUser.empty] otherwise
///
/// Available functions:
/// - [logout] - logs out the current user
///
/// Available states:
/// - [Authenticated] - the user is authenticated
/// - [Unauthenticated] - the user is not authenticated
///
class AuthCubit extends Cubit<AuthState> {
  AuthCubit({
    AuthService? authService,
  })  : _authService = authService ?? AuthService(),
        super(const Unauthenticated()) {
    _userSubscription = _authService.user.listen(_onUserChanged);
  }

  final AuthService _authService;
  late final StreamSubscription<CurrentUser> _userSubscription;

  void _onUserChanged(CurrentUser currentUser) {
    emit(
      currentUser.isNotEmpty
          ? Authenticated(currentUser)
          : const Unauthenticated(),
    );
  }

  CurrentUser get currentUser {
    switch (state) {
      case Authenticated():
        return (state as Authenticated).currentUser;
      case Unauthenticated():
        return CurrentUser.empty;
    }
  }

  void logout() {
    unawaited(_authService.logout());
  }

  @override
  Future<void> close() {
    _userSubscription.cancel();
    return super.close();
  }
}
