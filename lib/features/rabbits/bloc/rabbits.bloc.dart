import 'package:equatable/equatable.dart';
import 'package:bloc/bloc.dart';

import 'package:spk_app_frontend/features/rabbits/models/models.dart';
import 'package:spk_app_frontend/features/rabbits/repositories/repositories.dart';

part 'rabbits.event.dart';
part 'rabbits.state.dart';

class RabbitsBloc extends Bloc<RabbitsEvent, RabbitsState> {
  RabbitsBloc(RabbitsRepository rabbitsRepository)
      : _rabbitsRepository = rabbitsRepository,
        super(const RabbitsState()) {
    on<RabbitsFeached>(_onRabbitsFeached);
  }

  final RabbitsRepository _rabbitsRepository;

  Future<void> _onRabbitsFeached(
      RabbitsFeached event, Emitter<RabbitsState> emit) async {
    if (state.hasReachedMax) return;
    try {
      if (state.status == RabbitsStatus.initial) {
        final rabbits = await _fetchRabbits();
        return emit(RabbitsState(
          status: RabbitsStatus.success,
          rabbits: rabbits,
          hasReachedMax: false,
        ));
      }
      final rabbits = await _fetchRabbits();
      emit(rabbits.isEmpty
          ? state.copyWith(hasReachedMax: true)
          : state.copyWith(
              status: RabbitsStatus.success,
              rabbits: List.of(state.rabbits)..addAll(rabbits),
              hasReachedMax: false,
            ));
    } catch (_) {
      emit(state.copyWith(status: RabbitsStatus.failure));
    }
  }

  Future<List<RabbitsGroup>> _fetchRabbits() async {
    return await _rabbitsRepository.myRabbits();
  }
}
