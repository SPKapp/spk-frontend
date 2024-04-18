import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:spk_app_frontend/common/views/views.dart';
import 'package:spk_app_frontend/features/rabbit-notes/bloc/rabbit_notes_list.bloc.dart';
import 'package:spk_app_frontend/features/rabbit-notes/models/models.dart';

class RabbitNotesListView extends StatelessWidget {
  const RabbitNotesListView({
    super.key,
    required this.rabbitNotes,
    required this.hasReachedMax,
  });

  final List<RabbitNote> rabbitNotes;
  final bool hasReachedMax;

  @override
  Widget build(BuildContext context) {
    return AppListView<RabbitNote>(
      items: rabbitNotes,
      hasReachedMax: hasReachedMax,
      onRefresh: () async {
        Future bloc = context.read<RabbitNotesListBloc>().stream.first;
        context.read<RabbitNotesListBloc>().add(const RefreshRabbitNotes(null));
        return bloc;
      },
      onFetch: () {
        context.read<RabbitNotesListBloc>().add(const FetchRabbitNotes());
      },
      emptyMessage: 'Brak notatek.',
      itemBuilder: (dynamic note) => Text('test ${(note as RabbitNote).id}'),
    );
  }
}
