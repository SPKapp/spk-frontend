import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import 'package:spk_app_frontend/common/bloc/debounce.transformer.dart';

import 'package:spk_app_frontend/features/rabbit-notes/models/dto.dart';
import 'package:spk_app_frontend/features/rabbit-notes/models/models.dart';
import 'package:spk_app_frontend/features/rabbit-notes/repositories/interfaces.dart';

part 'rabbit_notes_list.event.dart';
part 'rabbit_notes_list.state.dart';

/// A bloc that manages the state of a list with rabbitNotes.
///
/// A bloc needs a [rabbitNoteRepository] to fetch the rabbitNotes and [args] to configure initial filter arguments, this arguments can be changed later with [RefreshRabbitNotes] event.
///
/// The bloc provides [FetchRabbitNotes] event to fetch next page and [RefreshRabbitNotes] event to restart fetching to first page.
/// If [RefreshRabbitNotes] event is dispatched with [args] the bloc will use this new arguments otherwise it will previous arguments.
///
/// It emits [RabbitNotesListInitial] state when the bloc is created or refreshed, [RabbitNotesListSuccess] state when the rabbitNotes are fetched successfully and [RabbitNotesListFailure] state when an error occurs while fetching rabbitNotes, this state also contains previous successful fetched rabbitNotes.
class RabbitNotesListBloc
    extends Bloc<RabbitNotesListEvent, RabbitNotesListState> {
  RabbitNotesListBloc({
    required IRabbitNoteRepository rabbitNoteRepository,
    required FindRabbitNotesArgs args,
  })  : _rabbitNoteRepository = rabbitNoteRepository,
        _args = args,
        super(const RabbitNotesListInitial()) {
    on<FetchRabbitNotes>(
      _onFetch,
      transformer: debounceTransformer(const Duration(milliseconds: 500)),
    );
    on<RefreshRabbitNotes>(_onRefresh);
  }

  final IRabbitNoteRepository _rabbitNoteRepository;
  FindRabbitNotesArgs _args;

  void _onFetch(
      FetchRabbitNotes event, Emitter<RabbitNotesListState> emit) async {
    if (state.hasReachedMax) return;

    try {
      final paginatedResult = await _rabbitNoteRepository.findAll(
        _args.copyWith(offset: state.rabbitNotes.length),
        state.totalCount == 0,
      );

      final totalCount = paginatedResult.totalCount ?? state.totalCount;
      final newData = state.rabbitNotes + paginatedResult.data;

      emit(RabbitNotesListSuccess(
        rabbitNotes: newData,
        hasReachedMax: newData.length >= totalCount,
        totalCount: totalCount,
      ));
    } catch (e) {
      emit(RabbitNotesListFailure(
        rabbitNotes: state.rabbitNotes,
        hasReachedMax: state.hasReachedMax,
        totalCount: state.totalCount,
      ));
    }
  }

  void _onRefresh(
      RefreshRabbitNotes event, Emitter<RabbitNotesListState> emit) async {
    _args = event.args ?? _args;
    emit(const RabbitNotesListInitial());
    add(const FetchRabbitNotes());
  }
}
