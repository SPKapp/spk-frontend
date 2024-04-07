part of 'regions_list.bloc.dart';

sealed class RegionsListState extends Equatable {
  const RegionsListState({
    this.regions = const [],
    this.hasReachedMax = false,
    this.totalCount = 0,
  });

  final List<Region> regions;
  final bool hasReachedMax;
  final int totalCount;

  @override
  List<Object> get props => [regions, hasReachedMax, totalCount];
}

final class RegionsListInitial extends RegionsListState {
  const RegionsListInitial();
}

final class RegionsListSuccess extends RegionsListState {
  const RegionsListSuccess({
    required super.regions,
    required super.hasReachedMax,
    required super.totalCount,
  });
}

final class RegionsListFailure extends RegionsListState {
  const RegionsListFailure({
    super.regions,
    super.hasReachedMax,
    super.totalCount,
  });
}
