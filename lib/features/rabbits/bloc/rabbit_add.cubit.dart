import 'package:equatable/equatable.dart';
import 'package:bloc/bloc.dart';

import 'package:spk_app_frontend/features/rabbits/models/dto/dto.dart';
import 'package:spk_app_frontend/features/rabbits/repositories/repositories.dart';

part 'rabbit_add.state.dart';

class RabbitAddCubit extends Cubit<RabbitAddState> {
  RabbitAddCubit({
    required RabbitsRepository rabbitsRepository,
  })  : _rabbitsRepository = rabbitsRepository,
        super(const RabbitAddInitial());

  final RabbitsRepository _rabbitsRepository;

  void addRabbit(RabbitCreateDto rabbit) async {
    try {
      if (rabbit.rabbitGroupId == null) {
        // TODO: add correct group id and region id
        rabbit.regionId = 1;
      }
      final id = await _rabbitsRepository.createRabbit(rabbit);
      emit(
        RabbitCreated(
          rabbitId: id,
        ),
      );
    } catch (e) {
      emit(
        const RabbitAddFailure(),
      );
      emit(
        const RabbitAddInitial(),
      );
    }
  }
}
