part of 'regions_and_teams.cubit.dart';

sealed class RegionsAndTeamsState extends Equatable {
  const RegionsAndTeamsState();

  @override
  List<Object> get props => [];
}

final class RegionsAndTeamsInitial extends RegionsAndTeamsState {
  const RegionsAndTeamsInitial();
}

final class RegionsAndTeamsSuccess extends RegionsAndTeamsState {
  const RegionsAndTeamsSuccess({
    required this.regions,
    required this.teams,
  });

  final Iterable<Region> regions;
  final Iterable<Team> teams;

  @override
  List<Object> get props => [regions, teams];
}

final class RegionsAndTeamsFailure extends RegionsAndTeamsState {
  const RegionsAndTeamsFailure();
}
