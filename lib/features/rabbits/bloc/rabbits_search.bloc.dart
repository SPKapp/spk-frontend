import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import 'package:spk_app_frontend/common/bloc/debounce.transformer.dart';

import 'package:spk_app_frontend/features/rabbits/models/models.dart';
import 'package:spk_app_frontend/features/rabbits/repositories/interfaces.dart';

part 'rabbits_search.event.dart';
part 'rabbits_search.state.dart';

class RabbitsSearchBloc extends Bloc<RabbitsSearchEvent, RabbitsSearchState> {
  RabbitsSearchBloc({
    required IRabbitsRepository rabbitsRepository,
  })  : _rabbitsRepository = rabbitsRepository,
        super(const RabbitsSearchInitial()) {
    on<RabbitsSearchQueryChanged>(
      _onQueryChanged,
      transformer: debounceTransformer(const Duration(milliseconds: 500)),
    );

    on<RabbitsSearchFetch>(
      _onFetchNextPage,
      transformer: debounceTransformer(const Duration(milliseconds: 500)),
    );

    on<RabbitsSearchClear>(_onClear);
  }

  final IRabbitsRepository _rabbitsRepository;

  void _onQueryChanged(
    RabbitsSearchQueryChanged event,
    Emitter<RabbitsSearchState> emit,
  ) async {
    if (state.query == event.query) return;

    try {
      final result = await _rabbitsRepository.findRabbitsByName(event.query,
          totalCount: true);
      emit(RabbitsSearchSuccess(
        query: event.query,
        rabbits: result.data,
        hasReachedMax: result.data.length >= result.totalCount!,
        totalCount: result.totalCount!,
      ));
    } catch (_) {
      emit(const RabbitsSearchFailure());
    }
  }

  void _onFetchNextPage(
    RabbitsSearchFetch event,
    Emitter<RabbitsSearchState> emit,
  ) async {
    if (state.hasReachedMax) return;

    try {
      final result = await _rabbitsRepository.findRabbitsByName(
        state.query,
        offset: state.rabbits.length,
      );

      final rabbits = state.rabbits + result.data;

      emit(RabbitsSearchSuccess(
        query: state.query,
        rabbits: rabbits,
        hasReachedMax: rabbits.length >= state.totalCount,
        totalCount: state.totalCount,
      ));
    } catch (_) {
      emit(RabbitsSearchFailure(
        query: state.query,
        rabbits: state.rabbits,
        hasReachedMax: state.hasReachedMax,
        totalCount: state.totalCount,
      ));
    }
  }

  void _onClear(
    RabbitsSearchClear event,
    Emitter<RabbitsSearchState> emit,
  ) {
    emit(const RabbitsSearchInitial());
  }
}
