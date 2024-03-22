import 'package:equatable/equatable.dart';
import 'package:bloc/bloc.dart';

import 'package:spk_app_frontend/features/rabbits/models/models.dart';
import 'package:spk_app_frontend/features/rabbits/repositories/interfaces.dart';

part 'rabbit.state.dart';

class RabbitCubit extends Cubit<RabbitState> {
  RabbitCubit({
    required this.rabbitId,
    required IRabbitsRepository rabbitsRepository,
  })  : _rabbitsRepository = rabbitsRepository,
        super(const RabbitInitial());

  final int rabbitId;
  final IRabbitsRepository _rabbitsRepository;

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
}
