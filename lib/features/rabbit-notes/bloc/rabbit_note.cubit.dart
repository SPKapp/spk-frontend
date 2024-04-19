import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import 'package:spk_app_frontend/features/rabbit-notes/models/models.dart';
import 'package:spk_app_frontend/features/rabbit-notes/repositories/interfaces.dart';

part 'rabbit_note.state.dart';

/// A Cubit that manages the state of a RabbitNote.
///
/// Available functions:
/// - [fetchRabbitNote] - fetches the RabbitNote with the given [rabbitNoteId]
/// - [refreshRabbitNote] - restarts fetching the RabbitNote
///
/// Available states:
/// - [RabbitNoteInitial] - initial state
/// - [RabbitNoteSuccess] - the RabbitNote has been fetched successfully
/// - [RabbitNoteFailure] - an error occurred while fetching the RabbitNote
class RabbitNoteCubit extends Cubit<RabbitNoteState> {
  RabbitNoteCubit({
    required this.rabbitNoteId,
    required IRabbitNotesRepository rabbitNotesRepository,
  })  : _rabbitNotesRepository = rabbitNotesRepository,
        super(const RabbitNoteInitial());

  final int rabbitNoteId;
  final IRabbitNotesRepository _rabbitNotesRepository;

  /// Fetches the RabbitNote with the given [rabbitNoteId].
  /// Emits new state only if data was changed.
  void fetchRabbitNote() async {
    try {
      final rabbitNote = await _rabbitNotesRepository.findOne(
        rabbitNoteId,
      );
      emit(
        RabbitNoteSuccess(
          rabbitNote: rabbitNote,
        ),
      );
    } catch (e) {
      emit(
        const RabbitNoteFailure(),
      );
    }
  }

  /// Restarts fetching the RabbitNote.
  /// Always emits new state.
  void refreshRabbitNote() async {
    emit(
      const RabbitNoteInitial(),
    );
    fetchRabbitNote();
  }
}
