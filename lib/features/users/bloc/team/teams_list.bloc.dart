import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import 'package:spk_app_frontend/common/bloc/debounce.transformer.dart';
import 'package:spk_app_frontend/common/services/logger.service.dart';
import 'package:spk_app_frontend/features/users/models/dto.dart';

import 'package:spk_app_frontend/features/users/models/models.dart';
import 'package:spk_app_frontend/features/users/repositories/interfaces.dart';

part 'teams_list.event.dart';
part 'teams_list.state.dart';

/// A bloc that manages the state of a list with teams.
///
/// Available functions:
/// - [FetchUsers] - fetches the next page of teams
/// it uses the previous arguments to fetch the next page
/// - [RefreshUsers] - restarts fetching the teams with the given arguments
/// if no arguments are provided it will use the previous arguments otherwise new arguments will be used
///
/// Available states:
/// - [UsersListInitial] - initial state
/// - [UsersListSuccess] - the teams have been fetched successfully
/// - [UsersListFailure] - an error occurred while fetching the teams
///
class TeamsListBloc extends Bloc<TeamsListEvent, TeamsListState> {
  TeamsListBloc({
    required ITeamsRepository teamsRepository,
    required FindTeamsArgs args,
  })  : _teamsRepository = teamsRepository,
        _args = args,
        super(TeamsListInitial()) {
    on<FetchTeams>(
      _onFetchUsers,
      transformer: debounceTransformer(const Duration(milliseconds: 500)),
    );
    on<RefreshTeams>(_onRefreshUsers);
  }

  final ITeamsRepository _teamsRepository;
  final logger = LoggerService();
  FindTeamsArgs _args;

  FindTeamsArgs get args => _args;

  void _onFetchUsers(FetchTeams event, Emitter<TeamsListState> emit) async {
    if (state.hasReachedMax) return;

    try {
      final paginatedResult = await _teamsRepository.findAll(
        _args.copyWith(offset: () => state.teams.length),
        state.totalCount == 0,
      );

      final totalCount = paginatedResult.totalCount ?? state.totalCount;
      final newData = state.teams + paginatedResult.data;

      emit(TeamsListSuccess(
        teams: newData,
        hasReachedMax: newData.length >= totalCount,
        totalCount: totalCount,
      ));
    } catch (e) {
      logger.error('Error while fetching teams', error: e);
      emit(TeamsListFailure(
        teams: state.teams,
        hasReachedMax: state.hasReachedMax,
        totalCount: state.totalCount,
      ));
    }
  }

  void _onRefreshUsers(RefreshTeams event, Emitter<TeamsListState> emit) async {
    _args = event.args ?? _args;
    emit(TeamsListInitial());
    add(const FetchTeams());
  }
}
