import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import 'package:spk_app_frontend/features/rabbit-notes/models/models.dart';
import 'package:spk_app_frontend/features/rabbit-notes/repositories/interfaces.dart';

part 'rabbit_note.state.dart';

/// A Cubit that manages the state of a RabbitNote.
///
/// A cubit needs a [IRabbitNotesRepository] and [rabbitNoteId] to fetch the RabbitNote.
///
/// It provides [fetchRabbitNote] method to fetch - this mettod emits
/// new state only if data was changed.
/// It also provides [refreshRabbitNote] method to restart fetching,
/// this metod emits [RabbitNoteInitial] state before fetching.
class RabbitNoteCubit extends Cubit<RabbitNoteState> {
  RabbitNoteCubit({
    required this.rabbitNoteId,
    required IRabbitNotesRepository rabbitNotesRepository,
  })  : _rabbitNotesRepository = rabbitNotesRepository,
        super(const RabbitNoteInitial());

  final int rabbitNoteId;
  final IRabbitNotesRepository _rabbitNotesRepository;

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

  void refreshRabbitNote() async {
    emit(
      const RabbitNoteInitial(),
    );
    fetchRabbitNote();
  }
}
