part of 'app.bloc.dart';

enum AppStatus {
  authenticated,
  unauthenticated,
}

final class AppState extends Equatable {
  const AppState._({
    this.status = AppStatus.unauthenticated,
    this.currentUser = CurrentUser.empty,
  });

  final AppStatus status;
  final CurrentUser currentUser;

  const AppState.authenticated(CurrentUser currentUser)
      : this._(
          status: AppStatus.authenticated,
          currentUser: currentUser,
        );

  const AppState.unauthenticated() : this._(status: AppStatus.unauthenticated);

  @override
  List<Object> get props => [status, currentUser];
}
