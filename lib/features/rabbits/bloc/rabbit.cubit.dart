import 'package:spk_app_frontend/common/bloc/interfaces/get_one.cubit.interface.dart';
import 'package:spk_app_frontend/features/rabbits/models/models.dart';
import 'package:spk_app_frontend/features/rabbits/repositories/interfaces.dart';

/// A cubit that manages the state of a rabbit.
///
/// Needs a [rabbitId] and a [rabbitsRepository].
class RabbitCubit extends IGetOneCubit<Rabbit> {
  RabbitCubit({
    required this.rabbitId,
    required IRabbitsRepository rabbitsRepository,
  })  : _rabbitsRepository = rabbitsRepository,
        super();

  final String rabbitId;
  final IRabbitsRepository _rabbitsRepository;

  /// Fetches a rabbit with the given [rabbitId].
  /// Emits new state only if data was changed.
  @override
  void fetch() async {
    try {
      final rabbit = await _rabbitsRepository.findOne(rabbitId);
      emit(GetOneSuccess(data: rabbit));
    } catch (e) {
      logger.error('Failed to fetch rabbit', error: e);
      emit(const GetOneFailure());
    }
  }
}
