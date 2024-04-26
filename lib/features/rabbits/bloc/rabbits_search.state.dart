part of 'rabbits_search.bloc.dart';

sealed class RabbitsSearchState extends Equatable {
  RabbitsSearchState({
    this.query = '',
    this.rabbitGroups = const [],
    this.hasReachedMax = false,
    this.totalCount = 0,
  }) : _rabbits = rabbitGroups.expand((group) => group.rabbits).toList();

  final String query;
  final List<RabbitGroup> rabbitGroups;
  final List<Rabbit> _rabbits;
  final bool hasReachedMax;
  final int totalCount;

  List<Rabbit> get rabbits => _rabbits;
  @override
  List<Object> get props => [query, rabbitGroups, hasReachedMax, totalCount];
}

final class RabbitsSearchInitial extends RabbitsSearchState {
  RabbitsSearchInitial();
}

final class RabbitsSearchSuccess extends RabbitsSearchState {
  RabbitsSearchSuccess({
    required super.query,
    required super.rabbitGroups,
    required super.hasReachedMax,
    required super.totalCount,
  });
}

final class RabbitsSearchFailure extends RabbitsSearchState {
  RabbitsSearchFailure({
    super.query,
    super.rabbitGroups,
    super.hasReachedMax,
    super.totalCount,
  });
}
