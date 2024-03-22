import 'package:equatable/equatable.dart';
import 'package:bloc/bloc.dart';

import 'package:spk_app_frontend/common/bloc/debounce.transformer.dart';
import 'package:spk_app_frontend/common/models/paginated.dto.dart';

import 'package:spk_app_frontend/features/rabbits/models/models.dart';
import 'package:spk_app_frontend/features/rabbits/repositories/interfaces.dart';

part 'rabbits.state.dart';
part 'rabbits.event.dart';

enum RabbitsQueryType { my, all }

/// A bloc that manages the state of a list with rabbitGroups.
///
/// The bloc can be configured with [queryType]
/// to fetch the rabbits of the volunteer [RabbitsQueryType.my]
/// or all rabbits [RabbitsQueryType.all].
class RabbitsBloc extends Bloc<RabbitsEvent, RabbitsState> {
  RabbitsBloc({
    required IRabbitsRepository rabbitsRepository,
    required RabbitsQueryType queryType,
  })  : _rabbitsRepository = rabbitsRepository,
        _queryType = queryType,
        super(RabbitsInitial()) {
    on<FeatchRabbits>(
      _onFetchRabbits,
      transformer: debounceTransformer(const Duration(milliseconds: 500)),
    );
  }

  final IRabbitsRepository _rabbitsRepository;
  final RabbitsQueryType _queryType;

  void _onFetchRabbits(FeatchRabbits event, Emitter<RabbitsState> emit) async {
    switch (_queryType) {
      case RabbitsQueryType.my:
        await _onFetchMyRabbits(emit);
      case RabbitsQueryType.all:
        await _onFetchAllRabbits(emit);
    }
  }

  Future<void> _onFetchMyRabbits(Emitter<RabbitsState> emit) async {
    try {
      switch (state) {
        case RabbitsInitial():
        case RabbitsFailure():
          final rabbits = await _rabbitsRepository.myRabbits();
          emit(RabbitsSuccess(
            rabbitsGroups: rabbits,
            hasReachedMax: true,
            totalCount: rabbits.length,
          ));
        case RabbitsSuccess():
          emit(state);
      }
    } catch (e) {
      emit(
        RabbitsFailure(),
      );
    }
  }

  Future<void> _onFetchAllRabbits(Emitter<RabbitsState> emit) async {
    if (state.hasReachedMax) return;

    final myState = state;

    try {
      late final Paginated<RabbitsGroup> result;

      switch (myState) {
        case RabbitsInitial():
          result = await _rabbitsRepository.findAll(totalCount: true);
          emit(RabbitsSuccess(
            rabbitsGroups: result.data,
            hasReachedMax: result.totalCount == result.data.length,
            totalCount: result.totalCount!,
          ));
        case RabbitsFailure():
        case RabbitsSuccess():
          result = await _rabbitsRepository.findAll(
            offset: myState.rabbitsGroups.length,
          );

          final list = List.of(myState.rabbitsGroups)..addAll(result.data);

          emit(RabbitsSuccess(
            rabbitsGroups: list,
            hasReachedMax: list.length == myState.totalCount,
            totalCount: myState.totalCount,
          ));
      }
    } catch (e) {
      emit(
        RabbitsFailure(),
      );
    }
  }
}
