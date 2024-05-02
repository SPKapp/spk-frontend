import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import 'package:spk_app_frontend/common/bloc/debounce.transformer.dart';
import 'package:spk_app_frontend/features/users/models/dto.dart';

import 'package:spk_app_frontend/features/users/models/models.dart';
import 'package:spk_app_frontend/features/users/repositories/interfaces.dart';

part 'users_list.event.dart';
part 'users_list.state.dart';

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
class UsersListBloc extends Bloc<UsersListEvent, UsersListState> {
  UsersListBloc({
    required IUsersRepository usersRepository,
    required FindUsersArgs args,
    int? perPage,
    List<int>? regionsIds,
  })  : _usersRepository = usersRepository,
        _args = args,
        super(UsersListInitial()) {
    on<FetchUsers>(
      _onFetchUsers,
      transformer: debounceTransformer(const Duration(milliseconds: 500)),
    );
    on<RefreshUsers>(_onRefreshUsers);
  }

  final IUsersRepository _usersRepository;
  FindUsersArgs _args;

  FindUsersArgs get args => _args;

  void _onFetchUsers(FetchUsers event, Emitter<UsersListState> emit) async {
    if (state.hasReachedMax) return;

    try {
      final paginatedResult = await _usersRepository.findAll(
        _args.copyWith(offset: () => state.teams.length),
        state.totalCount == 0,
      );

      final totalCount = paginatedResult.totalCount ?? state.totalCount;
      final newData = state.teams + paginatedResult.data;

      emit(UsersListSuccess(
        teams: newData,
        hasReachedMax: newData.length >= totalCount,
        totalCount: totalCount,
      ));
    } catch (e) {
      emit(UsersListFailure(
        teams: state.teams,
        hasReachedMax: state.hasReachedMax,
        totalCount: state.totalCount,
      ));
    }
  }

  void _onRefreshUsers(RefreshUsers event, Emitter<UsersListState> emit) async {
    _args = event.args ?? _args;
    emit(UsersListInitial());
    add(const FetchUsers());
  }
}
