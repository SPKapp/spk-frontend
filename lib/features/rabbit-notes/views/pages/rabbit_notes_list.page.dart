import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:spk_app_frontend/common/views/views.dart';
import 'package:spk_app_frontend/features/rabbit-notes/bloc/rabbit_notes_list.bloc.dart';
import 'package:spk_app_frontend/features/rabbit-notes/models/dto.dart';
import 'package:spk_app_frontend/features/rabbit-notes/repositories/interfaces.dart';
import 'package:spk_app_frontend/features/rabbit-notes/views/views/rabbit_notes_list.view.dart';
import 'package:spk_app_frontend/features/rabbit-notes/views/widgets/list_page/rabbit_notes_list_filters.widget.dart';

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

  final int rabbitId;
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
                )..add(const FetchRabbitNotes()),
        child: BlocConsumer<RabbitNotesListBloc, RabbitNotesListState>(
          listener: (context, state) {
            if (state is RabbitNotesListFailure &&
                state.rabbitNotes.isNotEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  key: Key('errorSnackBar'),
                  content: Text(
                    'Wystąpił błąd podczas pobierania notatek.',
                  ),
                ),
              );
            }
          },
          buildWhen: (previous, current) =>
              previous is! RabbitNotesListSuccess ||
              current is RabbitNotesListSuccess,
          builder: (context, state) {
            late Widget body;

            switch (state) {
              case RabbitNotesListInitial():
                body = const InitialView();
              case RabbitNotesListFailure():
                body = FailureView(
                  message: 'Wystąpił błąd podczas wczytywania notatek',
                  onPressed: () => context
                      .read<RabbitNotesListBloc>()
                      .add(const RefreshRabbitNotes(null)),
                );
              case RabbitNotesListSuccess():
                body = RabbitNotesListView(
                  rabbitNotes: state.rabbitNotes,
                  hasReachedMax: state.hasReachedMax,
                  rabbitName: rabbitName,
                );
            }

            return Scaffold(
              appBar: AppBar(
                title: Text(rabbitName ?? 'Historia Notatek'),
                actions: [
                  IconButton(
                    key: const Key('filterAction'),
                    icon: const Icon(Icons.filter_alt),
                    onPressed: () => showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      builder: (_) => BlocProvider.value(
                        value: context.read<RabbitNotesListBloc>(),
                        child: RabbitNotesListFilters(
                          args: context.read<RabbitNotesListBloc>().args,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              floatingActionButton: FloatingActionButton(
                key: const Key('addNoteButton'),
                onPressed: () =>
                    context.push('/rabbit/$rabbitId/note/create', extra: {
                  'isVetVisit':
                      context.read<RabbitNotesListBloc>().args.isVetVisit ==
                          true,
                  'rabbitName': rabbitName,
                }),
                child: const Icon(Icons.add),
              ),
              body: body,
            );
          },
        ),
      );
}
