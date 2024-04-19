import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:spk_app_frontend/common/views/views.dart';
import 'package:spk_app_frontend/features/rabbit-notes/bloc/rabbit_notes_list.bloc.dart';
import 'package:spk_app_frontend/features/rabbit-notes/models/models.dart';
import 'package:spk_app_frontend/features/rabbit-notes/views/widgets/list_page/rabbit_notes_list_item.widget.dart';

/// A view that displays a list of rabbit notes.
///
/// This view assumes that the [RabbitNotesListBloc] is already provided above in the widget tree. Use FetchRabbitNotes to fetch new notes and RefreshRabbitNotes to refresh the list.
/// If [rabbitName] is provided, then it will be passed to the [RabbitNoteListItem] widget.
class RabbitNotesListView extends StatelessWidget {
  const RabbitNotesListView({
    super.key,
    required this.rabbitNotes,
    required this.hasReachedMax,
    this.rabbitName,
  });

  final List<RabbitNote> rabbitNotes;
  final bool hasReachedMax;
  final String? rabbitName;

  @override
  Widget build(BuildContext context) {
    return AppListView<RabbitNote>(
      items: rabbitNotes,
      hasReachedMax: hasReachedMax,
      onRefresh: () async {
        // skip initial state
        Future bloc = context.read<RabbitNotesListBloc>().stream.skip(1).first;
        context.read<RabbitNotesListBloc>().add(const RefreshRabbitNotes(null));
        return bloc;
      },
      onFetch: () {
        context.read<RabbitNotesListBloc>().add(const FetchRabbitNotes());
      },
      emptyMessage: 'Brak notatek.',
      itemBuilder: (dynamic note) => RabbitNoteListItem(
        rabbitNote: note,
        rabbitName: rabbitName,
      ),
    );
  }
}
