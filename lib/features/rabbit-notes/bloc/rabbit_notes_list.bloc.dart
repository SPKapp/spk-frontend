import 'package:meta/meta.dart';

import 'package:spk_app_frontend/common/bloc/interfaces/get_list.bloc.interface.dart';
import 'package:spk_app_frontend/common/models/paginated.dto.dart';
import 'package:spk_app_frontend/features/rabbit-notes/models/dto.dart';
import 'package:spk_app_frontend/features/rabbit-notes/models/models.dart';
import 'package:spk_app_frontend/features/rabbit-notes/repositories/interfaces.dart';

/// A bloc that manages the state of a list with rabbitNotes.
///
/// This bloc is used to fetch the list of rabbitNotes.
///
class RabbitNotesListBloc
    extends IGetListBloc<RabbitNote, FindRabbitNotesArgs> {
  RabbitNotesListBloc({
    required IRabbitNotesRepository rabbitNoteRepository,
    required super.args,
  }) : _rabbitNoteRepository = rabbitNoteRepository;

  final IRabbitNotesRepository _rabbitNoteRepository;

  @override
  @visibleForOverriding
  Future<Paginated<RabbitNote>> fetchData() {
    return _rabbitNoteRepository.findAll(
      args.copyWith(offset: () => state.data.length),
      state.totalCount == 0,
    );
  }

  @override
  @visibleForOverriding
  String? createErrorCode(Object error) {
    logger.error('Error fetching RabbitNotes', error: error);
    return null;
  }
}
