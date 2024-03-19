part of 'rabbits.bloc.dart';

sealed class RabbitsState extends Equatable {
  const RabbitsState();

  @override
  List<Object?> get props => [];
}

final class RabbitsInitial extends RabbitsState {
  const RabbitsInitial();
}

final class RabbitsSuccess extends RabbitsState {
  const RabbitsSuccess({
    required this.rabbitsGroups,
    required this.hasReachedMax,
  });

  final List<RabbitsGroup> rabbitsGroups;
  final bool hasReachedMax;

  RabbitsSuccess copyWith({
    List<RabbitsGroup>? rabbitsGroups,
    bool? hasReachedMax,
  }) {
    return RabbitsSuccess(
      rabbitsGroups: rabbitsGroups ?? this.rabbitsGroups,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
    );
  }

  @override
  List<Object?> get props => [rabbitsGroups, hasReachedMax];
}

final class RabbitsFailure extends RabbitsState {
  const RabbitsFailure();
}
