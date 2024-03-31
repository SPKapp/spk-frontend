part of 'rabbits_search.bloc.dart';

sealed class RabbitsSearchState extends Equatable {
  const RabbitsSearchState({
    this.query = '',
    this.rabbits = const [],
    this.hasReachedMax = false,
    this.totalCount = 0,
  });

  final String query;
  final List<Rabbit> rabbits;
  final bool hasReachedMax;
  final int totalCount;

  @override
  List<Object> get props => [query, rabbits, hasReachedMax, totalCount];
}

final class RabbitsSearchInitial extends RabbitsSearchState {
  const RabbitsSearchInitial();
}

final class RabbitsSearchSuccess extends RabbitsSearchState {
  const RabbitsSearchSuccess({
    required super.query,
    required super.rabbits,
    required super.hasReachedMax,
    required super.totalCount,
  });
}

final class RabbitsSearchFailure extends RabbitsSearchState {
  const RabbitsSearchFailure({
    super.query,
    super.rabbits,
    super.hasReachedMax,
    super.totalCount,
  });
}
