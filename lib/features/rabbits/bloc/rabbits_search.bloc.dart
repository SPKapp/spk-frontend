import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import 'package:spk_app_frontend/common/bloc/debounce.transformer.dart';
import 'package:spk_app_frontend/features/rabbits/models/dto.dart';
import 'package:spk_app_frontend/features/rabbits/models/models.dart';
import 'package:spk_app_frontend/features/rabbits/repositories/interfaces.dart';

part 'rabbits_search.event.dart';
part 'rabbits_search.state.dart';

/// A bloc that manages the state of a list with rabbitGroups.
///
/// Available functions:
/// - [RabbitsSearchFetch] - fetches the next page of rabbits
/// - [RabbitsSearchRefresh] - restarts fetching the rabbits with the given name
/// - [RabbitsSearchClear] - clears the search query
///
/// Available states:
/// - [RabbitsSearchInitial] - initial state
/// - [RabbitsSearchSuccess] - the rabbits have been fetched successfully
/// - [RabbitsSearchFailure] - an error occurred while fetching the rabbits
///
class RabbitsSearchBloc extends Bloc<RabbitsSearchEvent, RabbitsSearchState> {
  RabbitsSearchBloc({
    required IRabbitsRepository rabbitsRepository,
    required FindRabbitsArgs args,
  })  : _rabbitsRepository = rabbitsRepository,
        _args = args,
        super(RabbitsSearchInitial()) {
    on<RabbitsSearchRefresh>(
      _onRefresh,
      transformer: debounceTransformer(const Duration(milliseconds: 500)),
    );

    on<RabbitsSearchFetch>(
      _onFetchNextPage,
      transformer: debounceTransformer(const Duration(milliseconds: 500)),
    );

    on<RabbitsSearchClear>(_onClear);
  }

  final IRabbitsRepository _rabbitsRepository;
  FindRabbitsArgs _args;

  void _onFetchNextPage(
    RabbitsSearchFetch event,
    Emitter<RabbitsSearchState> emit,
  ) async {
    if (state.hasReachedMax) return;

    if (_args.name == null || _args.name!.isEmpty) {
      emit(RabbitsSearchInitial());
      return;
    }

    try {
      final paginatedResult = await _rabbitsRepository.findAll(
        _args.copyWith(offset: () => state.rabbitGroups.length),
        state.totalCount == 0,
      );

      final totalCount = paginatedResult.totalCount ?? state.totalCount;
      final newData = state.rabbitGroups + paginatedResult.data;

      emit(RabbitsSearchSuccess(
        query: _args.name ?? '',
        rabbitGroups: newData,
        hasReachedMax: newData.length >= totalCount,
        totalCount: totalCount,
      ));
    } catch (_) {
      emit(RabbitsSearchFailure(
        query: state.query,
        rabbitGroups: state.rabbitGroups,
        hasReachedMax: state.hasReachedMax,
        totalCount: state.totalCount,
      ));
    }
  }

  void _onRefresh(
    RabbitsSearchRefresh event,
    Emitter<RabbitsSearchState> emit,
  ) async {
    _args = _args.copyWith(name: () => event.query, offset: () => 0);
    emit(RabbitsSearchInitial());
    add(const RabbitsSearchFetch());
  }

  void _onClear(
    RabbitsSearchClear event,
    Emitter<RabbitsSearchState> emit,
  ) {
    _args = _args.copyWith(name: () => null, offset: () => 0);
    emit(RabbitsSearchInitial());
  }
}
