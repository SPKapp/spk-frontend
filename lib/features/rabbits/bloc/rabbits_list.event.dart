part of 'rabbits_list.bloc.dart';

sealed class RabbitsListEvent extends Equatable {
  const RabbitsListEvent();

  @override
  List<Object?> get props => [];
}

final class FetchRabbits extends RabbitsListEvent {
  const FetchRabbits();
}

final class RefreshRabbits extends RabbitsListEvent {
  const RefreshRabbits(this.args);

  final FindRabbitsArgs? args;

  @override
  List<Object?> get props => [args];
}
