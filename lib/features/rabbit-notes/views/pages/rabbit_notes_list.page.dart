import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:spk_app_frontend/common/bloc/interfaces/get_list.bloc.interface.dart';
import 'package:spk_app_frontend/common/views/pages/get_list.page.dart';

import 'package:spk_app_frontend/features/rabbit-notes/bloc/rabbit_notes_list.bloc.dart';
import 'package:spk_app_frontend/features/rabbit-notes/models/dto.dart';
import 'package:spk_app_frontend/features/rabbit-notes/models/models.dart';
import 'package:spk_app_frontend/features/rabbit-notes/repositories/interfaces.dart';
import 'package:spk_app_frontend/features/rabbit-notes/views/widgets/list_page/rabbit_notes_list_filters.widget.dart';
import 'package:spk_app_frontend/features/rabbit-notes/views/widgets/list_page/rabbit_notes_list_item.widget.dart';

/// A page that displays a list of rabbit notes.
///
/// If [rabbitName] is not provided, it displays a default title "Historia Notatek". Otherwise, it displays the provided name.
///
/// This page assumes that the [IRabbitNotesRepository] is already provided above in the widget tree.
class RabbitNotesListPage extends StatelessWidget {
  const RabbitNotesListPage({
    super.key,
    required this.rabbitId,
    this.rabbitName,
    this.isVetVisit,
    this.rabbitNotesListBloc,
  });

  final String rabbitId;
  final String? rabbitName;
  final bool? isVetVisit;
  final RabbitNotesListBloc Function(BuildContext)? rabbitNotesListBloc;

  @override
  Widget build(BuildContext context) => BlocProvider(
        create: rabbitNotesListBloc ??
            (context) => RabbitNotesListBloc(
                  rabbitNoteRepository: context.read<IRabbitNotesRepository>(),
                  args: FindRabbitNotesArgs(
                    rabbitId: rabbitId,
                    isVetVisit: isVetVisit,
                  ),
                )..add(const FetchList()),
        child: Builder(builder: (context) {
          return GetListPage<RabbitNote, FindRabbitNotesArgs,
              RabbitNotesListBloc>(
            title: rabbitName ?? 'Historia Notatek',
            errorInfo: 'Wystąpił błąd podczas pobierania notatek.',
            filterBuilder: (context, args, callback) => RabbitNotesListFilters(
              args: args,
              onFilter: callback,
            ),
            floatingActionButton: FloatingActionButton(
              key: const Key('addNoteButton'),
              onPressed: () =>
                  context.push('/rabbit/$rabbitId/note/create', extra: {
                'isVetVisit':
                    context.read<RabbitNotesListBloc>().args.isVetVisit == true,
                'rabbitName': rabbitName,
              }),
              child: const Icon(Icons.add),
            ),
            emptyMessage: 'Brak notatek.',
            itemBuilder: (context, rabbitNote) => RabbitNoteListItem(
              rabbitNote: rabbitNote,
              rabbitName: rabbitName,
            ),
          );
        }),
      );
}
