part of 'rabbits_search.bloc.dart';

sealed class RabbitsSearchEvent extends Equatable {
  const RabbitsSearchEvent();

  @override
  List<Object> get props => [];
}

/// Get first page of search results
final class RabbitsSearchRefresh extends RabbitsSearchEvent {
  const RabbitsSearchRefresh(this.query);

  final String query;

  @override
  List<Object> get props => [query];
}

/// Fetch next page of search results
final class RabbitsSearchFetch extends RabbitsSearchEvent {
  const RabbitsSearchFetch();
}

/// Clear results
final class RabbitsSearchClear extends RabbitsSearchEvent {
  const RabbitsSearchClear();
}
