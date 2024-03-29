import 'package:equatable/equatable.dart';
import 'package:bloc/bloc.dart';

import 'package:spk_app_frontend/common/bloc/debounce.transformer.dart';

import 'package:spk_app_frontend/features/rabbits/models/models.dart';
import 'package:spk_app_frontend/features/rabbits/repositories/interfaces.dart';

part 'rabbits_list.state.dart';
part 'rabbits_list.event.dart';

enum RabbitsQueryType { my, all }

/// A bloc that manages the state of a list with rabbitGroups.
///
/// The bloc can be configured with [queryType]
/// to fetch the rabbits of the volunteer [RabbitsQueryType.my]
/// or all rabbits [RabbitsQueryType.all].
class RabbitsListBloc extends Bloc<RabbitsListEvent, RabbitsListState> {
  RabbitsListBloc({
    required IRabbitsRepository rabbitsRepository,
    required RabbitsQueryType queryType,
  })  : _rabbitsRepository = rabbitsRepository,
        _queryType = queryType,
        super(RabbitsListInitial()) {
    on<FetchRabbits>(
      _onFetchRabbits,
      transformer: debounceTransformer(const Duration(milliseconds: 500)),
    );
    on<RefreshRabbits>(_onRefreshRabbits);
  }

  final IRabbitsRepository _rabbitsRepository;
  final RabbitsQueryType _queryType;

  void _onFetchRabbits(
      FetchRabbits event, Emitter<RabbitsListState> emit) async {
    switch (_queryType) {
      case RabbitsQueryType.my:
        await _onFetchMyRabbits(emit);
      case RabbitsQueryType.all:
        await _onFetchAllRabbits(emit);
    }
  }

  Future<void> _onFetchMyRabbits(Emitter<RabbitsListState> emit) async {
    try {
      // TODO: To analyze
      switch (state) {
        case RabbitsListInitial():
        case RabbitsListFailure():
          final rabbits = await _rabbitsRepository.myRabbits();
          emit(RabbitsListSuccess(
            rabbitsGroups: rabbits,
            hasReachedMax: true,
            totalCount: rabbits.length,
          ));
        case RabbitsListSuccess():
          emit(state);
      }
    } catch (e) {
      emit(
        RabbitsListFailure(),
      );
    }
  }

  Future<void> _onFetchAllRabbits(Emitter<RabbitsListState> emit) async {
    if (state.hasReachedMax) return;

    final myState = state;

    try {
      final paginatedResult = await _rabbitsRepository.findAll(
        offset: myState.rabbitsGroups.length,
        totalCount: state is RabbitsListInitial,
      );

      final rabbitGroups = paginatedResult.data;
      final totalCount = (state is RabbitsListInitial)
          ? paginatedResult.totalCount!
          : myState.totalCount;

      emit(RabbitsListSuccess(
        rabbitsGroups: List.of(myState.rabbitsGroups)..addAll(rabbitGroups),
        hasReachedMax:
            myState.rabbitsGroups.length + rabbitGroups.length >= totalCount,
        totalCount: totalCount,
      ));
    } catch (e) {
      emit(
        RabbitsListFailure(
          rabbitsGroups: myState.rabbitsGroups,
          hasReachedMax: myState.hasReachedMax,
          totalCount: myState.totalCount,
        ),
      );
    }
  }

  void _onRefreshRabbits(
      RefreshRabbits event, Emitter<RabbitsListState> emit) async {
    emit(RabbitsListInitial());
    add(const FetchRabbits());
  }
}
