import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:spk_app_frontend/common/services/logger.service.dart';
import 'package:spk_app_frontend/features/rabbits/models/models.dart';
import 'package:spk_app_frontend/features/rabbits/repositories/interfaces.dart';

part 'rabbit_group.state.dart';

/// A cubit that manages the state of a rabbit group.
///
/// Available functions:
/// - [fetch] - fetches a rabbit group with the given [rabbitGroupId]
/// - [refresh] - restarts fetching the rabbit group
///
/// Available states:
/// - [RabbitGroupInitial] - initial state
/// - [RabbitGroupSuccess] - the rabbit group has been fetched successfully
/// - [RabbitGroupFailure] - an error occurred while fetching the rabbit group
class RabbitGroupCubit extends Cubit<RabbitGroupState> {
  RabbitGroupCubit({
    required this.rabbitGroupId,
    required IRabbitGroupsRepository rabbitGroupsRepository,
  })  : _rabbitGroupsRepository = rabbitGroupsRepository,
        super(const RabbitGroupInitial());

  final String rabbitGroupId;
  final IRabbitGroupsRepository _rabbitGroupsRepository;
  final logger = LoggerService();

  /// Fetches a rabbit group with the given [rabbitGroupId].
  /// Emits new state only if data was changed.
  void fetch() async {
    try {
      final rabbitGroup = await _rabbitGroupsRepository.findOne(rabbitGroupId);
      emit(RabbitGroupSuccess(rabbitGroup: rabbitGroup));
    } catch (e) {
      logger.error('Failed to fetch rabbit group', error: e);
      emit(const RabbitGroupFailure());
    }
  }

  /// Restarts fetching the rabbit group.
  /// Always emits new state.
  void refresh() async {
    emit(const RabbitGroupInitial());
    fetch();
  }
}
