part of 'rabbit_note_create.cubit.dart';

sealed class RabbitNoteCreateState extends Equatable {
  const RabbitNoteCreateState();

  @override
  List<Object> get props => [];
}

final class RabbitNoteCreateInitial extends RabbitNoteCreateState {
  const RabbitNoteCreateInitial();
}

final class RabbitNoteCreated extends RabbitNoteCreateState {
  const RabbitNoteCreated(
    this.rabbitNoteId,
  );

  final int rabbitNoteId;

  @override
  List<Object> get props => [rabbitNoteId];
}

final class RabbitNoteCreateFailure extends RabbitNoteCreateState {
  const RabbitNoteCreateFailure();
}
