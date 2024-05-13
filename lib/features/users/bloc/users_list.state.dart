part of 'users_list.bloc.dart';

sealed class UsersListState extends Equatable {
  const UsersListState({
    this.users = const [],
    this.hasReachedMax = false,
    this.totalCount = 0,
  });

  final List<User> users;
  final bool hasReachedMax;
  final int totalCount;

  @override
  List<Object> get props => [users, hasReachedMax, totalCount];
}

final class UsersListInitial extends UsersListState {
  const UsersListInitial();
}

final class UsersListSuccess extends UsersListState {
  const UsersListSuccess({
    required super.users,
    required super.hasReachedMax,
    required super.totalCount,
  });
}

final class UsersListFailure extends UsersListState {
  const UsersListFailure({
    super.users,
    super.hasReachedMax,
    super.totalCount,
  });
}
