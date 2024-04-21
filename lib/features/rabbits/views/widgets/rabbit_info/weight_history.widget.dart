import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:spk_app_frontend/common/extensions/extensions.dart';
import 'package:spk_app_frontend/common/views/views.dart';
import 'package:spk_app_frontend/features/rabbit-notes/bloc/rabbit_notes_list.bloc.dart';
import 'package:spk_app_frontend/features/rabbit-notes/models/dto.dart';
import 'package:spk_app_frontend/features/rabbit-notes/models/models.dart';
import 'package:spk_app_frontend/features/rabbit-notes/repositories/interfaces.dart';

/// A widget that displays the weight history of a rabbit.
class WeightHistory extends StatelessWidget {
  const WeightHistory({
    super.key,
    required this.rabbitId,
    this.rabbitNotesListBloc,
  });

  final int rabbitId;
  final RabbitNotesListBloc Function(BuildContext)? rabbitNotesListBloc;

  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      widthFactor: 1.0,
      heightFactor: 0.70,
      child: BlocProvider(
        create: rabbitNotesListBloc ??
            (_) => RabbitNotesListBloc(
                  rabbitNoteRepository: context.read<IRabbitNotesRepository>(),
                  args:
                      FindRabbitNotesArgs(rabbitId: rabbitId, withWeight: true),
                )..add(const FetchRabbitNotes()),
        child: BlocBuilder<RabbitNotesListBloc, RabbitNotesListState>(
          builder: (context, state) {
            switch (state) {
              case RabbitNotesListInitial():
                return const InitialView();
              case RabbitNotesListFailure():
                return FailureView(
                  message: 'Nie udało się pobrać historii wagi królika.',
                  onPressed: () => context
                      .read<RabbitNotesListBloc>()
                      .add(const RefreshRabbitNotes(null)),
                );

              case RabbitNotesListSuccess():
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: NestedScrollView(
                    headerSliverBuilder: (context, innerBoxIsScrolled) => [
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            'Historia wagi królika',
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                        ),
                      ),
                    ],
                    body: AppListView<RabbitNote>(
                      emptyMessage: 'Brak danych',
                      hasReachedMax: state.hasReachedMax,
                      items: state.rabbitNotes,
                      onRefresh: () {
                        // skip initial state
                        Future bloc = context
                            .read<RabbitNotesListBloc>()
                            .stream
                            .skip(1)
                            .first;
                        context
                            .read<RabbitNotesListBloc>()
                            .add(const RefreshRabbitNotes(null));
                        return bloc;
                      },
                      onFetch: () {
                        context
                            .read<RabbitNotesListBloc>()
                            .add(const FetchRabbitNotes());
                      },
                      itemBuilder: (dynamic note) => ListTile(
                        leading: const Icon(FontAwesomeIcons.weightHanging),
                        title: Text(
                          'Waga: ${(note as RabbitNote).weight} kg',
                        ),
                        subtitle: Text(
                          'Data: ${note.vetVisit?.date?.toDateString() ?? note.createdAt?.toDateString()}',
                        ),
                      ),
                    ),
                  ),
                );
            }
          },
        ),
      ),
    );
  }
}
