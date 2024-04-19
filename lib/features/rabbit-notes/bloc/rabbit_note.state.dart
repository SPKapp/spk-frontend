part of 'rabbit_note.cubit.dart';

sealed class RabbitNoteState extends Equatable {
  const RabbitNoteState();

  @override
  List<Object> get props => [];
}

final class RabbitNoteInitial extends RabbitNoteState {
  const RabbitNoteInitial();
}

final class RabbitNoteSuccess extends RabbitNoteState {
  const RabbitNoteSuccess({
    required this.rabbitNote,
  });

  final RabbitNote rabbitNote;

  @override
  List<Object> get props => [rabbitNote];
}

final class RabbitNoteFailure extends RabbitNoteState {
  const RabbitNoteFailure();
}
