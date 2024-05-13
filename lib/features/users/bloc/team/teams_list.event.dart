part of 'teams_list.bloc.dart';

sealed class TeamsListEvent extends Equatable {
  const TeamsListEvent();

  @override
  List<Object?> get props => [];
}

final class FetchTeams extends TeamsListEvent {
  const FetchTeams();
}

final class RefreshTeams extends TeamsListEvent {
  const RefreshTeams(this.args);

  final FindTeamsArgs? args;

  @override
  List<Object?> get props => [args];
}
