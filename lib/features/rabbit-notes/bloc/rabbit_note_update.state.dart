part of 'rabbit_note_update.cubit.dart';

sealed class RabbitNoteUpdateState extends Equatable {
  const RabbitNoteUpdateState();

  @override
  List<Object> get props => [];
}

final class RabbitNoteUpdateInitial extends RabbitNoteUpdateState {
  const RabbitNoteUpdateInitial();
}

final class RabbitNoteUpdated extends RabbitNoteUpdateState {
  const RabbitNoteUpdated();
}

final class RabbitNoteUpdateFailure extends RabbitNoteUpdateState {
  const RabbitNoteUpdateFailure();
}
