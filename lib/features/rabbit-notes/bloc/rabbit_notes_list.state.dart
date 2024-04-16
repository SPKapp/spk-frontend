part of 'rabbit_notes_list.bloc.dart';

sealed class RabbitNotesListState extends Equatable {
  const RabbitNotesListState({
    this.rabbitNotes = const [],
    this.hasReachedMax = false,
    this.totalCount = 0,
  });

  final List<RabbitNote> rabbitNotes;
  final bool hasReachedMax;
  final int totalCount;

  @override
  List<Object> get props => [rabbitNotes, hasReachedMax, totalCount];
}

final class RabbitNotesListInitial extends RabbitNotesListState {
  const RabbitNotesListInitial();
}

final class RabbitNotesListSuccess extends RabbitNotesListState {
  const RabbitNotesListSuccess({
    required super.rabbitNotes,
    required super.hasReachedMax,
    required super.totalCount,
  });
}

final class RabbitNotesListFailure extends RabbitNotesListState {
  const RabbitNotesListFailure({
    super.rabbitNotes,
    super.hasReachedMax,
    super.totalCount,
  });
}
