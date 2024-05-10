import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:spk_app_frontend/common/services/logger.service.dart';

import 'package:spk_app_frontend/features/rabbit-notes/models/dto.dart';
import 'package:spk_app_frontend/features/rabbit-notes/repositories/interfaces.dart';

part 'rabbit_note_create.state.dart';

/// Cubit responsible for managing the state of creating a rabbit note.
///
/// Available functions:
/// - [createRabbitNote] - creates a new rabbit note based on the provided [dto]
///
/// Available states:
/// - [RabbitNoteCreateInitial] - initial state
/// - [RabbitNoteCreated] - the rabbit note has been created successfully
/// - [RabbitNoteCreateFailure] - an error occurred while creating the rabbit note
///
class RabbitNoteCreateCubit extends Cubit<RabbitNoteCreateState> {
  RabbitNoteCreateCubit({
    required IRabbitNotesRepository rabbitNotesRepository,
  })  : _rabbitNotesRepository = rabbitNotesRepository,
        super(const RabbitNoteCreateInitial());

  final IRabbitNotesRepository _rabbitNotesRepository;
  final logger = LoggerService();

  /// Creates a new rabbit note based on the provided [dto].
  void createRabbitNote(RabbitNoteCreateDto dto) async {
    try {
      final rabbitNoteId = await _rabbitNotesRepository.create(dto);
      emit(
        RabbitNoteCreated(rabbitNoteId),
      );
    } catch (e) {
      logger.error('Error while creating a rabbit note', error: e);
      emit(
        const RabbitNoteCreateFailure(),
      );
    }
  }
}
