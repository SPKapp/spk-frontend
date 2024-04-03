part of 'rabbits_list.bloc.dart';

sealed class RabbitsListState extends Equatable {
  const RabbitsListState({
    this.rabbitGroups = const [],
    this.hasReachedMax = false,
    this.totalCount = 0,
  });

  final List<RabbitGroup> rabbitGroups;
  final bool hasReachedMax;
  final int totalCount;

  @override
  List<Object> get props => [rabbitGroups, hasReachedMax, totalCount];
}

final class RabbitsListInitial extends RabbitsListState {
  const RabbitsListInitial();
}

final class RabbitsListSuccess extends RabbitsListState {
  const RabbitsListSuccess({
    required super.rabbitGroups,
    required super.hasReachedMax,
    required super.totalCount,
  });
}

final class RabbitsListFailure extends RabbitsListState {
  const RabbitsListFailure({
    super.rabbitGroups,
    super.hasReachedMax,
    super.totalCount,
  });
}
