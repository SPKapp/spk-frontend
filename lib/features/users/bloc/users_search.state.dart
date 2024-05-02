part of 'users_search.bloc.dart';

sealed class UsersSearchState extends Equatable {
  UsersSearchState({
    this.query = '',
    this.teams = const [],
    this.hasReachedMax = false,
    this.totalCount = 0,
  }) : _users = teams.expand((team) => team.users).toList();

  final String query;
  final List<Team> teams;
  final List<User> _users;
  final bool hasReachedMax;
  final int totalCount;

  List<User> get users => _users;
  @override
  List<Object> get props => [query, teams, hasReachedMax, totalCount];
}

final class UsersSearchInitial extends UsersSearchState {
  UsersSearchInitial();
}

final class UsersSearchSuccess extends UsersSearchState {
  UsersSearchSuccess({
    required super.query,
    required super.teams,
    required super.hasReachedMax,
    required super.totalCount,
  });
}

final class UsersSearchFailure extends UsersSearchState {
  UsersSearchFailure({
    super.query,
    super.teams,
    super.hasReachedMax,
    super.totalCount,
  });
}
