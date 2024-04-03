part of 'users_search.bloc.dart';

sealed class UsersSearchState extends Equatable {
  const UsersSearchState({
    this.query = '',
    this.users = const [],
    this.hasReachedMax = false,
    this.totalCount = 0,
  });

  final String query;
  final List<User> users;
  final bool hasReachedMax;
  final int totalCount;

  @override
  List<Object> get props => [query, users, hasReachedMax, totalCount];
}

final class UsersSearchInitial extends UsersSearchState {
  const UsersSearchInitial();
}

final class UsersSearchSuccess extends UsersSearchState {
  const UsersSearchSuccess({
    required super.query,
    required super.users,
    required super.hasReachedMax,
    required super.totalCount,
  });
}

final class UsersSearchFailure extends UsersSearchState {
  const UsersSearchFailure({
    super.query,
    super.users,
    super.hasReachedMax,
    super.totalCount,
  });
}
