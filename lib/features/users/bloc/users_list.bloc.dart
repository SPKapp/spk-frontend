import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import 'package:spk_app_frontend/common/bloc/debounce.transformer.dart';

import 'package:spk_app_frontend/features/users/models/models.dart';
import 'package:spk_app_frontend/features/users/repositories/interfaces.dart';

part 'users_list.event.dart';
part 'users_list.state.dart';

/// The [UsersListBloc] class is responsible for managing the state of the users list.
/// It provide [FetchUsers] event to fetch next page of users and [RefreshUsers] event to restart fetching users.
/// It emits [UsersListInitial] state when the bloc is created, [UsersListSuccess] state when the users are fetched successfully
/// and [UsersListFailure] state when an error occurs while fetching users, this state also contains previous successful fetched users.
class UsersListBloc extends Bloc<UsersListEvent, UsersListState> {
  UsersListBloc({
    required IUsersRepository usersRepository,
  })  : _usersRepository = usersRepository,
        super(UsersListInitial()) {
    on<FetchUsers>(
      _onFetchUsers,
      transformer: debounceTransformer(const Duration(milliseconds: 500)),
    );
    on<RefreshUsers>(_onRefreshUsers);
  }

  final IUsersRepository _usersRepository;

  void _onFetchUsers(FetchUsers event, Emitter<UsersListState> emit) async {
    if (state.hasReachedMax) return;

    try {
      final paginatedTeams = await _usersRepository.fetchTeams(
        offset: state.teams.length,
        totalCount: state is UsersListInitial,
      );

      final teams = paginatedTeams.data;
      final totalCount = (state is UsersListInitial)
          ? paginatedTeams.totalCount!
          : state.totalCount;

      emit(UsersListSuccess(
        teams: List.of(state.teams)..addAll(teams),
        hasReachedMax: state.teams.length + teams.length >= totalCount,
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
    emit(UsersListInitial());
    add(const FetchUsers());
  }
}
