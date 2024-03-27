part of 'users_list.bloc.dart';

sealed class UsersListEvent extends Equatable {
  const UsersListEvent();

  @override
  List<Object> get props => [];
}

final class FetchUsers extends UsersListEvent {
  const FetchUsers();
}

final class RefreshUsers extends UsersListEvent {
  const RefreshUsers();
}
