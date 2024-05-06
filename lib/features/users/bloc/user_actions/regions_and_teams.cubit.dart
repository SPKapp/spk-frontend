import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import 'package:spk_app_frontend/features/regions/models/models.dart';
import 'package:spk_app_frontend/features/users/models/models.dart';
import 'package:spk_app_frontend/features/users/repositories/interfaces.dart';

part 'regions_and_teams.state.dart';

/// Cubit responsible for fetching regions and teams.
///
/// It fetches regions and teams from the repository and emits the result.
///
/// Available functions:
/// - [fetch] - fetches regions and teams
///
/// Available states:
/// - [RegionsAndTeamsInitial] - initial state
/// - [RegionsAndTeamsSuccess] - emitted when fetching regions and teams is successful
/// - [RegionsAndTeamsFailure] - emitted when fetching regions and teams is unsuccessful
///
class RegionsAndTeamsCubit extends Cubit<RegionsAndTeamsState> {
  RegionsAndTeamsCubit({
    required ITeamsRepository teamsRepository,
  })  : _teamsRepository = teamsRepository,
        super(const RegionsAndTeamsInitial());

  final ITeamsRepository _teamsRepository;

  /// Fetches regions and teams.
  void fetch(Iterable<String>? regionsIds) async {
    try {
      final result = await _teamsRepository.fetchRegionsAndTeams(regionsIds);

      emit(RegionsAndTeamsSuccess(
        regions: result.$1,
        teams: result.$2,
      ));
    } catch (e) {
      emit(const RegionsAndTeamsFailure());
    }
  }
}
