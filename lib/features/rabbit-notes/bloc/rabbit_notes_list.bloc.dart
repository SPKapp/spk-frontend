import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import 'package:spk_app_frontend/common/bloc/debounce.transformer.dart';
import 'package:spk_app_frontend/common/services/logger.service.dart';
import 'package:spk_app_frontend/features/rabbit-notes/models/dto.dart';
import 'package:spk_app_frontend/features/rabbit-notes/models/models.dart';
import 'package:spk_app_frontend/features/rabbit-notes/repositories/interfaces.dart';

part 'rabbit_notes_list.event.dart';
part 'rabbit_notes_list.state.dart';

/// A bloc that manages the state of a list with rabbitNotes.
///
/// Available signals:
/// - [FetchRabbitNotes] - fetches the next page of rabbitNotes
/// it uses the previous arguments to fetch the next page
/// - [RefreshRabbitNotes] - restarts fetching the rabbitNotes with the given arguments
///  if no arguments are provided it will use the previous arguments otherwise new arguments will be used
///
/// Available states:
/// - [RabbitNotesListInitial] - initial state
/// - [RabbitNotesListSuccess] - the rabbitNotes have been fetched successfully
/// - [RabbitNotesListFailure] - an error occurred while fetching the rabbitNotes
class RabbitNotesListBloc
    extends Bloc<RabbitNotesListEvent, RabbitNotesListState> {
  RabbitNotesListBloc({
    required IRabbitNotesRepository rabbitNoteRepository,
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

  final IRabbitNotesRepository _rabbitNoteRepository;
  final logger = LoggerService();
  FindRabbitNotesArgs _args;

  FindRabbitNotesArgs get args => _args;

  void _onFetch(
      FetchRabbitNotes event, Emitter<RabbitNotesListState> emit) async {
    if (state.hasReachedMax) return;

    try {
      final paginatedResult = await _rabbitNoteRepository.findAll(
        _args.copyWith(offset: () => state.rabbitNotes.length),
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
      logger.error('Error while fetching RabbitNotes', error: e);
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
