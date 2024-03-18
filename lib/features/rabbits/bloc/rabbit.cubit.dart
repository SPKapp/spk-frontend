import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import 'package:spk_app_frontend/features/rabbits/repositories/rabbits.repository.dart';
import 'package:spk_app_frontend/features/rabbits/models/rabbit.model.dart';

part 'rabbit.state.dart';

class RabbitCubit extends Cubit<RabbitState> {
  RabbitCubit({
    required this.rabbitId,
    required rabbitsRepository,
  })  : _rabbitsRepository = rabbitsRepository,
        super(const RabbitInitial());

  final int rabbitId;
  final RabbitsRepository _rabbitsRepository;

  void fetchRabbit() async {
    try {
      final rabbit = await _rabbitsRepository.rabbit(rabbitId);
      emit(
        RabbitSuccess(
          rabbit: rabbit,
        ),
      );
    } catch (e) {
      emit(
        const RabbitFailure(),
      );
    }
  }

  void updateRabbit() async {
    try {
      final rabbit = await _rabbitsRepository.rabbit(rabbitId); // TODO: ???
      emit(
        RabbitUpdated(
          rabbit: rabbit,
        ),
      );
    } catch (e) {
      emit(
        const RabbitUpdateFailure(),
      );
    }
  }
}
