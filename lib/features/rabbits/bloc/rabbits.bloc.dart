import 'package:equatable/equatable.dart';
import 'package:bloc/bloc.dart';

import 'package:spk_app_frontend/common/bloc/debounce.transformer.dart';

import 'package:spk_app_frontend/features/rabbits/models/models.dart';
import 'package:spk_app_frontend/features/rabbits/repositories/repositories.dart';

part 'rabbits.state.dart';
part 'rabbits.event.dart';

enum RabbitsQueryType { my }

class RabbitsBloc extends Bloc<RabbitsEvent, RabbitsState> {
  RabbitsBloc({
    required RabbitsRepository rabbitsRepository,
    required RabbitsQueryType queryType,
  })  : _rabbitsRepository = rabbitsRepository,
        _queryType = queryType,
        super(const RabbitsInitial()) {
    on<FeatchRabbits>(
      _onFetchRabbits,
      transformer: debounceTransformer(const Duration(milliseconds: 500)),
    );
    on<FeatchMyRabbits>(_onFetchMyRabbits);
  }

  final RabbitsRepository _rabbitsRepository;
  final RabbitsQueryType _queryType;

  void _onFetchRabbits(FeatchRabbits event, Emitter<RabbitsState> emit) async {
    switch (_queryType) {
      case RabbitsQueryType.my:
        add(const FeatchMyRabbits());
    }
  }

  Future<void> _onFetchMyRabbits(
      FeatchMyRabbits event, Emitter<RabbitsState> emit) async {
    try {
      switch (state) {
        case RabbitsInitial():
        case RabbitsFailure():
          final rabbits = await _rabbitsRepository.myRabbits();
          emit(RabbitsSuccess(
            rabbitsGroups: rabbits,
            hasReachedMax: true,
          ));
        case RabbitsSuccess():
          emit(state);
      }
    } catch (e) {
      emit(
        const RabbitsFailure(),
      );
    }
  }
}
