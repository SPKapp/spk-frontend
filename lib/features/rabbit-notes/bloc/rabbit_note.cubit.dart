import 'package:spk_app_frontend/common/bloc/interfaces/get_one.cubit.interface.dart';
import 'package:spk_app_frontend/features/rabbit-notes/models/models.dart';
import 'package:spk_app_frontend/features/rabbit-notes/repositories/interfaces.dart';

/// A Cubit that manages the state of a RabbitNote.
///
/// Needs a [rabbitNoteId] and a [rabbitNotesRepository].
class RabbitNoteCubit extends IGetOneCubit<RabbitNote> {
  RabbitNoteCubit({
    required this.rabbitNoteId,
    required IRabbitNotesRepository rabbitNotesRepository,
  })  : _rabbitNotesRepository = rabbitNotesRepository,
        super();

  final String rabbitNoteId;
  final IRabbitNotesRepository _rabbitNotesRepository;

  /// Fetches the RabbitNote with the given [rabbitNoteId].
  /// Emits new state only if data was changed.
  @override
  void fetch() async {
    try {
      final rabbitNote = await _rabbitNotesRepository.findOne(
        rabbitNoteId,
      );
      emit(GetOneSuccess(data: rabbitNote));
    } catch (e) {
      logger.error('Error while fetching a RabbitNote', error: e);
      emit(const GetOneFailure());
    }
  }
}
