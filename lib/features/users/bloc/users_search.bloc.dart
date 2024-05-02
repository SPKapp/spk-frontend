import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import 'package:spk_app_frontend/common/bloc/debounce.transformer.dart';
import 'package:spk_app_frontend/features/users/models/dto.dart';

import 'package:spk_app_frontend/features/users/models/models.dart';
import 'package:spk_app_frontend/features/users/repositories/interfaces.dart';

part 'users_search.event.dart';
part 'users_search.state.dart';

/// A bloc that manages the state of a list with users.
///
/// Available functions:
/// - [UsersSearchFetch] - fetches the next page of users
/// - [UsersSearchRefresh] - restarts fetching the users with the given name
/// - [UsersSearchClear] - clears the search query
///
/// Available states:
/// - [UsersSearchInitial] - initial state
/// - [UsersSearchSuccess] - the users have been fetched successfully
/// - [UsersSearchFailure] - an error occurred while fetching the users
///
class UsersSearchBloc extends Bloc<UsersSearchEvent, UsersSearchState> {
  UsersSearchBloc({
    required IUsersRepository usersRepository,
    required FindUsersArgs args,
  })  : _usersRepository = usersRepository,
        _args = args,
        super(UsersSearchInitial()) {
    on<UsersSearchRefresh>(
      _onRefresh,
      transformer: debounceTransformer(const Duration(milliseconds: 500)),
    );

    on<UsersSearchFetch>(
      _onFetchNextPage,
      transformer: debounceTransformer(const Duration(milliseconds: 500)),
    );

    on<UsersSearchClear>(_onClear);
  }

  final IUsersRepository _usersRepository;
  FindUsersArgs _args;

  void _onFetchNextPage(
    UsersSearchFetch event,
    Emitter<UsersSearchState> emit,
  ) async {
    if (state.hasReachedMax) return;

    if (_args.name == null || _args.name!.isEmpty) {
      emit(UsersSearchInitial());
      return;
    }

    try {
      final paginatedResult = await _usersRepository.findAll(
        _args.copyWith(offset: () => state.teams.length),
        state.totalCount == 0,
      );

      final totalCount = paginatedResult.totalCount ?? state.totalCount;
      final newData = state.teams + paginatedResult.data;

      emit(UsersSearchSuccess(
        query: _args.name ?? '',
        teams: newData,
        hasReachedMax: newData.length >= totalCount,
        totalCount: totalCount,
      ));
    } catch (_) {
      emit(UsersSearchFailure(
        query: state.query,
        teams: state.teams,
        hasReachedMax: state.hasReachedMax,
        totalCount: state.totalCount,
      ));
    }
  }

  void _onRefresh(
    UsersSearchRefresh event,
    Emitter<UsersSearchState> emit,
  ) {
    _args = _args.copyWith(name: () => event.query, offset: () => 0);
    emit(UsersSearchInitial());
    add(const UsersSearchFetch());
  }

  void _onClear(
    UsersSearchClear event,
    Emitter<UsersSearchState> emit,
  ) {
    _args = _args.copyWith(name: () => '', offset: () => 0);
    emit(UsersSearchInitial());
  }
}
