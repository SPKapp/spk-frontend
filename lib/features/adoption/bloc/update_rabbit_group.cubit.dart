import 'package:spk_app_frontend/common/bloc/interfaces/update.cubit.interface.dart';
import 'package:spk_app_frontend/features/rabbits/models/dto.dart';
import 'package:spk_app_frontend/features/rabbits/repositories/interfaces.dart';

class UpdateRabbitGroupCubit extends IUpdateCubit {
  UpdateRabbitGroupCubit({
    required this.rabbitgroupId,
    required this.rabbitGroupsRepository,
  });

  final String rabbitgroupId;
  final IRabbitGroupsRepository rabbitGroupsRepository;

  void update(RabbitGroupUpdateDto dto) async {
    try {
      await rabbitGroupsRepository.update(rabbitgroupId, dto);
      emit(const UpdateSuccess());
    } catch (e) {
      error(e, 'Error updating rabbit group');
    }
  }
}
