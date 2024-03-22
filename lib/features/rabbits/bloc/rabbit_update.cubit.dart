import 'package:equatable/equatable.dart';
import 'package:bloc/bloc.dart';

import 'package:spk_app_frontend/features/rabbits/models/dto/dto.dart';
import 'package:spk_app_frontend/features/rabbits/repositories/repositories.dart';

part 'rabbit_update.state.dart';

class RabbitUpdateCubit extends Cubit<RabbitUpdateState> {
  RabbitUpdateCubit({
    required RabbitsRepository rabbitsRepository,
  })  : _rabbitsRepository = rabbitsRepository,
        super(const RabbitUpdateInitial());

  final RabbitsRepository _rabbitsRepository;

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
}
