import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:spk_app_frontend/common/services/logger.service.dart';
import 'package:spk_app_frontend/features/rabbits/models/dto.dart';
import 'package:spk_app_frontend/features/rabbits/repositories/interfaces.dart';

part 'update_rabbit_group.state.dart';

class UpdateRabbitGroupCubit extends Cubit<UpdateRabbitGroupState> {
  UpdateRabbitGroupCubit({
    required this.rabbitgroupId,
    required this.rabbitGroupsRepository,
  }) : super(const UpdateRabbitGroupInitial());

  final String rabbitgroupId;
  final IRabbitGroupsRepository rabbitGroupsRepository;
  final logger = LoggerService();

  void update(RabbitGroupUpdateDto dto) async {
    try {
      await rabbitGroupsRepository.update(rabbitgroupId, dto);
      emit(const UpdatedRabbitGroup());
    } catch (e) {
      logger.error('Error updating rabbit group', error: e);
      emit(const UpdateRabbitGroupFailure());
    }
  }
}
