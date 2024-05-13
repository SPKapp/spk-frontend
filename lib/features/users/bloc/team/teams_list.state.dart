part of 'teams_list.bloc.dart';

sealed class TeamsListState extends Equatable {
  TeamsListState({
    List<Team>? teams,
    this.hasReachedMax = false,
    this.totalCount = 0,
  }) : teams = teams ?? List.empty(growable: true);

  final List<Team> teams;
  final bool hasReachedMax;
  final int totalCount;

  @override
  List<Object> get props => [teams, hasReachedMax, totalCount];
}

final class TeamsListInitial extends TeamsListState {
  TeamsListInitial();
}

final class TeamsListSuccess extends TeamsListState {
  TeamsListSuccess({
    required super.teams,
    required super.hasReachedMax,
    required super.totalCount,
  });
}

final class TeamsListFailure extends TeamsListState {
  TeamsListFailure({
    super.teams,
    super.hasReachedMax,
    super.totalCount,
  });
}
