import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import 'package:spk_app_frontend/common/bloc/debounce.transformer.dart';

import 'package:spk_app_frontend/features/users/models/models.dart';
import 'package:spk_app_frontend/features/users/repositories/interfaces.dart';

part 'users_search.event.dart';
part 'users_search.state.dart';

class UsersSearchBloc extends Bloc<UsersSearchEvent, UsersSearchState> {
  UsersSearchBloc({
    required IUsersRepository usersRepository,
  })  : _usersRepository = usersRepository,
        super(const UsersSearchInitial()) {
    on<UsersSearchQueryChanged>(
      _onQueryChanged,
      transformer: debounceTransformer(const Duration(milliseconds: 500)),
    );

    on<UsersSearchFetch>(
      _onFetchNextPage,
      transformer: debounceTransformer(const Duration(milliseconds: 500)),
    );

    on<UsersSearchClear>(_onClear);
  }

  final IUsersRepository _usersRepository;

  void _onQueryChanged(
    UsersSearchQueryChanged event,
    Emitter<UsersSearchState> emit,
  ) async {
    if (state.query == event.query) return;

    try {
      final result =
          await _usersRepository.findUsersByName(event.query, totalCount: true);
      emit(UsersSearchSuccess(
        query: event.query,
        users: result.data,
        hasReachedMax: result.data.length >= result.totalCount!,
        totalCount: result.totalCount!,
      ));
    } catch (_) {
      emit(const UsersSearchFailure());
    }
  }

  void _onFetchNextPage(
    UsersSearchFetch event,
    Emitter<UsersSearchState> emit,
  ) async {
    if (state.hasReachedMax) return;

    try {
      final result = await _usersRepository.findUsersByName(
        state.query,
        offset: state.users.length,
      );

      final users = state.users + result.data;

      emit(UsersSearchSuccess(
        query: state.query,
        users: users,
        hasReachedMax: users.length >= state.totalCount,
        totalCount: state.totalCount,
      ));
    } catch (_) {
      emit(const UsersSearchFailure());
    }
  }

  void _onClear(
    UsersSearchClear event,
    Emitter<UsersSearchState> emit,
  ) {
    emit(const UsersSearchInitial());
  }
}
