import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import 'package:spk_app_frontend/features/auth/auth.service.dart';
import 'package:spk_app_frontend/features/auth/current_user.model.dart';
import 'package:spk_app_frontend/features/notifications/notifications.service.dart';

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
    required NotificationService notificationService,
  })  : _authService = authService ?? AuthService(),
        _notificationService = notificationService,
        super(const Unauthenticated()) {
    _userSubscription = _authService.user.listen(_onUserChanged);
  }

  final AuthService _authService;
  final NotificationService _notificationService;
  late final StreamSubscription<CurrentUser> _userSubscription;

  void _onUserChanged(CurrentUser currentUser) {
    if (currentUser.isNotEmpty) {
      _notificationService.register();
      emit(Authenticated(currentUser));
    } else {
      emit(const Unauthenticated());
    }
  }

  CurrentUser get currentUser {
    switch (state) {
      case Authenticated():
        return (state as Authenticated).currentUser;
      case Unauthenticated():
        return CurrentUser.empty;
    }
  }

  void logout() async {
    await _notificationService.deregister();
    unawaited(_authService.logout());
  }

  @override
  Future<void> close() {
    _userSubscription.cancel();
    return super.close();
  }
}
