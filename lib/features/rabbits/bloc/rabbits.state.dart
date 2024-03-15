part of 'rabbits.bloc.dart';

enum RabbitsStatus { initial, success, failure }

final class RabbitsState extends Equatable {
  const RabbitsState({
    this.status = RabbitsStatus.initial,
    this.rabbits = const <RabbitsGroup>[],
    this.hasReachedMax = false,
  });

  final RabbitsStatus status;
  final List<RabbitsGroup> rabbits;
  final bool hasReachedMax;

  RabbitsState copyWith({
    RabbitsStatus? status,
    List<RabbitsGroup>? rabbits,
    bool? hasReachedMax,
  }) {
    return RabbitsState(
      status: status ?? this.status,
      rabbits: rabbits ?? this.rabbits,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
    );
  }

  @override
  List<Object> get props => [status, rabbits, hasReachedMax];
}
