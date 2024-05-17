import 'package:spk_app_frontend/common/bloc/interfaces/get_one.cubit.interface.dart';
import 'package:spk_app_frontend/features/rabbits/models/models.dart';
import 'package:spk_app_frontend/features/rabbits/repositories/interfaces.dart';

/// A cubit that manages the state of a rabbit group.
///
/// Needs a [rabbitGroupId] and a [rabbitGroupsRepository].
class RabbitGroupCubit extends IGetOneCubit<RabbitGroup> {
  RabbitGroupCubit({
    required this.rabbitGroupId,
    required IRabbitGroupsRepository rabbitGroupsRepository,
  })  : _rabbitGroupsRepository = rabbitGroupsRepository,
        super();

  final String rabbitGroupId;
  final IRabbitGroupsRepository _rabbitGroupsRepository;

  /// Fetches a rabbit group with the given [rabbitGroupId].
  /// Emits new state only if data was changed.
  @override
  void fetch() async {
    try {
      final rabbitGroup = await _rabbitGroupsRepository.findOne(rabbitGroupId);
      emit(GetOneSuccess(data: rabbitGroup));
    } catch (e) {
      logger.error('Failed to fetch rabbit group', error: e);
      emit(const GetOneFailure());
    }
  }
}
