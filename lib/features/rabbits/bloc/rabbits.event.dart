part of 'rabbits.bloc.dart';

sealed class RabbitsEvent extends Equatable {
  const RabbitsEvent();

  @override
  List<Object> get props => [];
}

final class FeatchRabbits extends RabbitsEvent {
  const FeatchRabbits();
}

final class _FeatchMyRabbits extends RabbitsEvent {
  const _FeatchMyRabbits();
}

final class _FeatchAllRabbits extends RabbitsEvent {
  const _FeatchAllRabbits();
}
