part of 'rabbit_notes_list.bloc.dart';

sealed class RabbitNotesListEvent extends Equatable {
  const RabbitNotesListEvent();

  @override
  List<Object?> get props => [];
}

final class FetchRabbitNotes extends RabbitNotesListEvent {
  const FetchRabbitNotes();
}

final class RefreshRabbitNotes extends RabbitNotesListEvent {
  const RefreshRabbitNotes(this.args);

  final FindRabbitNotesArgs? args;

  @override
  List<Object?> get props => [args];
}
