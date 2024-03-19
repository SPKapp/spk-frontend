part of 'rabbits.bloc.dart';

sealed class RabbitsEvent extends Equatable {
  const RabbitsEvent();

  @override
  List<Object> get props => [];
}

final class FeatchRabbits extends RabbitsEvent {
  const FeatchRabbits();
}

final class FeatchMyRabbits extends RabbitsEvent {
  const FeatchMyRabbits();
}
