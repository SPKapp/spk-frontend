import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import 'package:spk_app_frontend/features/regions/models/models.dart';
import 'package:spk_app_frontend/features/users/models/models.dart';
import 'package:spk_app_frontend/features/users/repositories/interfaces.dart';

part 'regions_and_teams.state.dart';

class RegionsAndTeamsCubit extends Cubit<RegionsAndTeamsState> {
  RegionsAndTeamsCubit({
    required ITeamsRepository teamsRepository,
  })  : _teamsRepository = teamsRepository,
        super(const RegionsAndTeamsInitial());

  final ITeamsRepository _teamsRepository;

  Future<void> fetch(Iterable<String>? regionsIds) async {
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
