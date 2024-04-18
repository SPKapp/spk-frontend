import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spk_app_frontend/common/views/views.dart';

import 'package:spk_app_frontend/features/rabbit-notes/bloc/rabbit_notes_list.bloc.dart';
import 'package:spk_app_frontend/features/rabbit-notes/models/dto.dart';
import 'package:spk_app_frontend/features/rabbit-notes/repositories/interfaces.dart';
import 'package:spk_app_frontend/features/rabbit-notes/views/widgets/list_page/rabbit_notes_list_filters.widget.dart';

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
                  rabbitNoteRepository: context.read<IRabbitNoteRepository>(),
                  args: FindRabbitNotesArgs(
                    rabbitId: rabbitId,
                    isVetVisit: isVetVisit,
                  ),
                )..add(const FetchRabbitNotes()),
        child: BlocBuilder<RabbitNotesListBloc, RabbitNotesListState>(
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
                body = Center(
                  child: Text(
                      'Rabbit Notes List Page rabbitId: $rabbitId rabbitName: $rabbitName isVetVisit: $isVetVisit state: $state'),
                );
            }

            return Scaffold(
              appBar: AppBar(
                title: Text(rabbitName ?? 'Historia Notatek'),
                actions: [
                  IconButton(
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
              body: body,
            );
          },
        ),
      );
}
