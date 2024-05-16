import 'package:equatable/equatable.dart';
import 'package:bloc/bloc.dart';

import 'package:spk_app_frontend/features/rabbits/models/dto.dart';
import 'package:spk_app_frontend/features/rabbits/repositories/interfaces.dart';

part 'rabbit_update.state.dart';

/// A cubit that handles the state management for updating a rabbit.
///
/// Available functions:
/// - [updateRabbit] - updates the rabbit with the given [rabbit]
/// - [changeTeam] - changes the team of the rabbit with the given [rabbitGroupId] to the team with the given [teamId]
/// - [changeRabbitGroup] - changes the rabbit group of the rabbit with the given [rabbitId] to the rabbit group with the given [rabbitGroupId]
/// - [removeRabbit] - removes the rabbit with the given [rabbitId]
/// - [resetState] - resets the state to the initial state
///
/// Available states:
/// - [RabbitUpdateInitial] - initial state
/// - [RabbitUpdated] - the rabbit has been updated successfully
/// - [RabbitUpdateFailure] - an error occurred while updating the rabbit
///
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

  /// Changes the team of the rabbit group with the given [rabbitGroupId] to the team with the given [teamId].
  void changeTeam(String rabbitGroupId, String teamId) async {
    try {
      await _rabbitsRepository.updateTeam(rabbitGroupId, teamId);
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

  /// Changes the rabbit group of the rabbit with the given [rabbitId] to the rabbit group with the given [rabbitGroupId].
  void changeRabbitGroup(String rabbitId, String rabbitGroupId) async {
    try {
      await _rabbitsRepository.updateRabbitGroup(rabbitId, rabbitGroupId);
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

  /// Removes the rabbit with the given [rabbitId].
  void removeRabbit(String rabbitId) async {
    try {
      await _rabbitsRepository.removeRabbit(rabbitId);
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

  /// Resets the state to the initial state.
  void resetState() {
    emit(const RabbitUpdateInitial());
  }
}
