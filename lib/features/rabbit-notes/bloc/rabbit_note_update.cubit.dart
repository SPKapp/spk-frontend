import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import 'package:spk_app_frontend/features/rabbit-notes/repositories/interfaces.dart';

part 'rabbit_note_update.state.dart';

/// A cubit that handles the state management for updating a RabbitNote.
///
/// Available functions:
/// - [removeRabbitNote] - removes the RabbitNote with the given [rabbitNoteId]
/// - [resetState] - resets the state to the initial state
///
/// Available states:
/// - [RabbitNoteUpdateInitial] - initial state
/// - [RabbitNoteUpdated] - the RabbitNote has been updated successfully
/// - [RabbitNoteUpdateFailure] - an error occurred while updating the RabbitNote
///
class RabbitNoteUpdateCubit extends Cubit<RabbitNoteUpdateState> {
  RabbitNoteUpdateCubit({
    required this.rabbitNoteId,
    required IRabbitNotesRepository rabbitNotesRepository,
  })  : _rabbitNotesRepository = rabbitNotesRepository,
        super(const RabbitNoteUpdateInitial());

  final int rabbitNoteId;
  final IRabbitNotesRepository _rabbitNotesRepository;

  /// Removes the RabbitNote with the given [rabbitNoteId].
  void removeRabbitNote() async {
    try {
      await _rabbitNotesRepository.remove(rabbitNoteId);
      emit(
        const RabbitNoteUpdated(),
      );
    } catch (e) {
      emit(
        const RabbitNoteUpdateFailure(),
      );
    }
  }

  /// Resets the state to the initial state.
  void resetState() {
    emit(const RabbitNoteUpdateInitial());
  }
}
