import 'package:equatable/equatable.dart';
import 'package:bloc/bloc.dart';

import 'package:spk_app_frontend/features/rabbits/models/dto.dart';
import 'package:spk_app_frontend/features/rabbits/repositories/interfaces.dart';

part 'rabbit_create.state.dart';

/// A cubit that handles the state management for adding a rabbit.
class RabbitCreateCubit extends Cubit<RabbitCreateState> {
  RabbitCreateCubit({
    required IRabbitsRepository rabbitsRepository,
  })  : _rabbitsRepository = rabbitsRepository,
        super(const RabbitCreateInitial());

  final IRabbitsRepository _rabbitsRepository;

  /// Sends an create request for the [rabbit].
  void createRabbit(RabbitCreateDto rabbit) async {
    try {
      final id = await _rabbitsRepository.createRabbit(rabbit);
      emit(
        RabbitCreated(
          rabbitId: id,
        ),
      );
    } catch (e) {
      emit(
        const RabbitCreateFailure(),
      );
      emit(
        const RabbitCreateInitial(),
      );
    }
  }
}
