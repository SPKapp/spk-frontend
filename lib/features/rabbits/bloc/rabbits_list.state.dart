part of 'rabbits_list.bloc.dart';

sealed class RabbitsListState extends Equatable {
  const RabbitsListState({
    this.rabbitsGroups = const [],
    this.hasReachedMax = false,
    this.totalCount = 0,
  });

  final List<RabbitsGroup> rabbitsGroups;
  final bool hasReachedMax;
  final int totalCount;

  @override
  List<Object> get props => [rabbitsGroups, hasReachedMax, totalCount];
}

final class RabbitsListInitial extends RabbitsListState {
  const RabbitsListInitial();
}

final class RabbitsListSuccess extends RabbitsListState {
  const RabbitsListSuccess({
    required super.rabbitsGroups,
    required super.hasReachedMax,
    required super.totalCount,
  });
}

final class RabbitsListFailure extends RabbitsListState {
  const RabbitsListFailure({
    super.rabbitsGroups,
    super.hasReachedMax,
    super.totalCount,
  });
}
