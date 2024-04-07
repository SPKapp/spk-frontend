import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import 'package:spk_app_frontend/common/bloc/debounce.transformer.dart';

import 'package:spk_app_frontend/features/users/models/models.dart';
import 'package:spk_app_frontend/features/users/repositories/interfaces.dart';

part 'users_list.event.dart';
part 'users_list.state.dart';

/// The [UsersListBloc] class is responsible for managing the state of the users list.
///
/// If [perPage] is not provided, the default value is defined by backend, if set to 0 the backend will return all users.
/// if [regionsIds] is provided, the backend will return only users from these regions.
///
/// It provide [FetchUsers] event to fetch next page of users and [RefreshUsers] event to restart fetching users.
/// It emits [UsersListInitial] state when the bloc is created, [UsersListSuccess] state when the users are fetched successfully
/// and [UsersListFailure] state when an error occurs while fetching users, this state also contains previous successful fetched users.
class UsersListBloc extends Bloc<UsersListEvent, UsersListState> {
  UsersListBloc({
    required IUsersRepository usersRepository,
    int? perPage,
    List<int>? regionsIds,
  })  : _usersRepository = usersRepository,
        _perPage = perPage,
        _regionsIds = regionsIds,
        super(UsersListInitial()) {
    on<FetchUsers>(
      _onFetchUsers,
      transformer: debounceTransformer(const Duration(milliseconds: 500)),
    );
    on<RefreshUsers>(_onRefreshUsers);
  }

  final IUsersRepository _usersRepository;
  final int? _perPage;
  final List<int>? _regionsIds;

  void _onFetchUsers(FetchUsers event, Emitter<UsersListState> emit) async {
    if (state.hasReachedMax) return;

    try {
      final paginatedTeams = await _usersRepository.fetchTeams(
        offset: state.teams.length,
        limit: _perPage,
        regionsIds: _regionsIds,
        totalCount: state is UsersListInitial,
      );

      final teams = paginatedTeams.data;
      final totalCount = (state is UsersListInitial)
          ? paginatedTeams.totalCount!
          : state.totalCount;

      emit(UsersListSuccess(
        teams: state.teams + teams,
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
