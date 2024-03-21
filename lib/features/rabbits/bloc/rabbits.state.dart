part of 'rabbits.bloc.dart';

sealed class RabbitsState extends Equatable {
  RabbitsState({
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

final class RabbitsInitial extends RabbitsState {
  RabbitsInitial();
}

final class RabbitsSuccess extends RabbitsState {
  RabbitsSuccess({
    required super.rabbitsGroups,
    required super.hasReachedMax,
    required super.totalCount,
  });
}

final class RabbitsFailure extends RabbitsState {
  RabbitsFailure();
}
