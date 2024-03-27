part of 'users_list.bloc.dart';

sealed class UsersListState extends Equatable {
  UsersListState({
    List<Team>? teams,
    this.hasReachedMax = false,
    this.totalCount = 0,
  }) : teams = teams ?? List.empty(growable: true);

  final List<Team> teams;
  final bool hasReachedMax;
  final int totalCount;

  @override
  List<Object> get props => [teams, hasReachedMax, totalCount];
}

final class UsersListInitial extends UsersListState {
  UsersListInitial();
}

final class UsersListSuccess extends UsersListState {
  UsersListSuccess({
    required super.teams,
    required super.hasReachedMax,
    required super.totalCount,
  });
}

final class UsersListFailure extends UsersListState {
  UsersListFailure({
    super.teams,
    super.hasReachedMax,
    super.totalCount,
  });
}
