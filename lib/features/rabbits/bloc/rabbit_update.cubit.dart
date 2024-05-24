import 'package:spk_app_frontend/common/bloc/interfaces/update.cubit.interface.dart';
import 'package:spk_app_frontend/features/rabbits/models/dto.dart';
import 'package:spk_app_frontend/features/rabbits/models/models.dart';
import 'package:spk_app_frontend/features/rabbits/repositories/interfaces.dart';

/// A cubit that handles the state management for updating a rabbit.
///
/// Available functions:
/// - [updateRabbit] - updates the rabbit with the given [rabbit]
/// - [changeTeam] - changes the team of the rabbit with the given [rabbitGroupId] to the team with the given [teamId]
/// - [changeRabbitGroup] - changes the rabbit group of the rabbit with the given [rabbitId] to the rabbit group with the given [rabbitGroupId]
/// - [removeRabbit] - removes the rabbit with the given [rabbitId]
/// - [changeRabbitStatus] - changes the status of the rabbit with the given [rabbitId] to the status with the given [status]
///
class RabbitUpdateCubit extends IUpdateCubit {
  RabbitUpdateCubit({
    required IRabbitsRepository rabbitsRepository,
  }) : _rabbitsRepository = rabbitsRepository;

  final IRabbitsRepository _rabbitsRepository;

  /// Sends an update request for the [rabbit].
  void updateRabbit(RabbitUpdateDto rabbit) async {
    try {
      await _rabbitsRepository.updateRabbit(rabbit);
      emit(
        const UpdateSuccess(),
      );
    } catch (e) {
      error(e, 'Failed to update rabbit');
    }
  }

  /// Changes the team of the rabbit group with the given [rabbitGroupId] to the team with the given [teamId].
  void changeTeam(String rabbitGroupId, String teamId) async {
    try {
      await _rabbitsRepository.updateTeam(rabbitGroupId, teamId);
      emit(
        const UpdateSuccess(),
      );
    } catch (e) {
      error(e, 'Failed to change team');
    }
  }

  /// Changes the rabbit group of the rabbit with the given [rabbitId] to the rabbit group with the given [rabbitGroupId].
  void changeRabbitGroup(String rabbitId, String rabbitGroupId) async {
    try {
      await _rabbitsRepository.updateRabbitGroup(rabbitId, rabbitGroupId);
      emit(
        const UpdateSuccess(),
      );
    } catch (e) {
      error(e, 'Failed to change rabbit group');
    }
  }

  /// Removes the rabbit with the given [rabbitId].
  void removeRabbit(String rabbitId) async {
    try {
      await _rabbitsRepository.removeRabbit(rabbitId);
      emit(
        const UpdateSuccess(),
      );
    } catch (e) {
      error(e, 'Failed to remove rabbit');
    }
  }

  void changeRabbitStatus(String rabbitId, RabbitStatus status) async {
    try {
      await _rabbitsRepository.changeRabbitStatus(rabbitId, status);
      emit(const UpdateSuccess());
    } catch (e) {
      error(e, 'Failed to change rabbit status');
    }
  }
}
