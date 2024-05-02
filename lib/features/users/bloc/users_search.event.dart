part of 'users_search.bloc.dart';

sealed class UsersSearchEvent extends Equatable {
  const UsersSearchEvent();

  @override
  List<Object> get props => [];
}

/// Get first page of search results
final class UsersSearchRefresh extends UsersSearchEvent {
  const UsersSearchRefresh(this.query);

  final String query;

  @override
  List<Object> get props => [query];
}

/// Fetch next page of search results
final class UsersSearchFetch extends UsersSearchEvent {
  const UsersSearchFetch();
}

/// Clear results
final class UsersSearchClear extends UsersSearchEvent {
  const UsersSearchClear();
}
