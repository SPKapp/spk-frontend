import 'package:equatable/equatable.dart';
import 'package:bloc/bloc.dart';

import 'package:spk_app_frontend/features/rabbits/models/models.dart';
import 'package:spk_app_frontend/features/rabbits/repositories/interfaces.dart';

part 'rabbit.state.dart';

/// A cubit that manages the state of a rabbit.
///
/// Available functions:
/// - [fetchRabbit] - fetches a rabbit with the given [rabbitId]
/// - [refreshRabbit] - restarts fetching the rabbit
///
/// Available states:
/// - [RabbitInitial] - initial state
/// - [RabbitSuccess] - the rabbit has been fetched successfully
/// - [RabbitFailure] - an error occurred while fetching the rabbit
///
class RabbitCubit extends Cubit<RabbitState> {
  RabbitCubit({
    required this.rabbitId,
    required IRabbitsRepository rabbitsRepository,
  })  : _rabbitsRepository = rabbitsRepository,
        super(const RabbitInitial());

  final int rabbitId;
  final IRabbitsRepository _rabbitsRepository;

  /// Fetches a rabbit with the given [rabbitId].
  /// Emits new state only if data was changed.
  void fetchRabbit() async {
    try {
      final rabbit = await _rabbitsRepository.rabbit(rabbitId);
      emit(
        RabbitSuccess(
          rabbit: rabbit,
        ),
      );
    } catch (e) {
      print(e);
      emit(
        const RabbitFailure(),
      );
    }
  }

  /// Restarts fetching the rabbit.
  /// Always emits new state.
  void refreshRabbit() async {
    emit(
      const RabbitInitial(),
    );
    fetchRabbit();
  }
}
