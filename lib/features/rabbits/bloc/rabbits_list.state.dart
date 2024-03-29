part of 'rabbits_list.bloc.dart';

sealed class RabbitsListState extends Equatable {
  RabbitsListState({
    List<RabbitsGroup>? rabbitsGroups,
    this.hasReachedMax = false,
    this.totalCount = 0,
  }) : rabbitsGroups = rabbitsGroups ?? List.empty(growable: true);

  final List<RabbitsGroup> rabbitsGroups;
  final bool hasReachedMax;
  final int totalCount;

  @override
  List<Object> get props => [rabbitsGroups, hasReachedMax, totalCount];
}

final class RabbitsListInitial extends RabbitsListState {
  RabbitsListInitial();
}

final class RabbitsListSuccess extends RabbitsListState {
  RabbitsListSuccess({
    required super.rabbitsGroups,
    required super.hasReachedMax,
    required super.totalCount,
  });
}

final class RabbitsListFailure extends RabbitsListState {
  RabbitsListFailure({
    super.rabbitsGroups,
    super.hasReachedMax,
    super.totalCount,
  });
}
