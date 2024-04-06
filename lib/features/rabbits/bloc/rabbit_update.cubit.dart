import 'package:equatable/equatable.dart';
import 'package:bloc/bloc.dart';

import 'package:spk_app_frontend/features/rabbits/models/dto.dart';
import 'package:spk_app_frontend/features/rabbits/repositories/interfaces.dart';

part 'rabbit_update.state.dart';

/// A cubit that handles the state management for updating a rabbit.
class RabbitUpdateCubit extends Cubit<RabbitUpdateState> {
  RabbitUpdateCubit({
    required IRabbitsRepository rabbitsRepository,
  })  : _rabbitsRepository = rabbitsRepository,
        super(const RabbitUpdateInitial());

  final IRabbitsRepository _rabbitsRepository;

  /// Sends an update request for the [rabbit].
  void updateRabbit(RabbitUpdateDto rabbit) async {
    try {
      await _rabbitsRepository.updateRabbit(rabbit);
      emit(
        const RabbitUpdated(),
      );
    } catch (e) {
      emit(
        const RabbitUpdateFailure(),
      );
      emit(
        const RabbitUpdateInitial(),
      );
    }
  }

  void changeTeam(int rabbitGroupId, int teamId) async {
    try {
      await _rabbitsRepository.changeTeam(rabbitGroupId, teamId);
      emit(
        const RabbitUpdated(),
      );
    } catch (e) {
      emit(
        const RabbitUpdateFailure(),
      );
      emit(
        const RabbitUpdateInitial(),
      );
    }
  }
}
