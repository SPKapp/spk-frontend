import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:spk_app_frontend/common/views/views.dart';
import 'package:spk_app_frontend/common/views/widgets/actions.dart';

import 'package:spk_app_frontend/features/rabbits/bloc/rabbits_list.bloc.dart';
import 'package:spk_app_frontend/features/rabbits/bloc/rabbits_search.bloc.dart';
import 'package:spk_app_frontend/features/rabbits/repositories/interfaces.dart';
import 'package:spk_app_frontend/features/rabbits/views/views/rabbits_list.view.dart';
import 'package:spk_app_frontend/features/rabbits/views/views/rabbits_search_list.view.dart';

/// A page that displays a list of rabbits.
///
/// This widget assumes that the [IRabbitsRepository] is provided above by [RepositoryProvider].
class RabbitsListPage extends StatelessWidget {
  const RabbitsListPage({
    super.key,
    this.drawer,
    this.rabbitsListBloc,
    this.rabbitsSearchBloc,
  });

  final Widget? drawer;
  final RabbitsListBloc Function(BuildContext)? rabbitsListBloc;
  final RabbitsSearchBloc Function(BuildContext)? rabbitsSearchBloc;

  @override
  Widget build(BuildContext context) => MultiBlocProvider(
        providers: [
          BlocProvider(
            create: rabbitsListBloc ??
                (context) => RabbitsListBloc(
                      rabbitsRepository: context.read<IRabbitsRepository>(),
                      queryType: RabbitsQueryType.all,
                    )..add(const FetchRabbits()),
          ),
          BlocProvider(
            create: rabbitsSearchBloc ??
                (context) => RabbitsSearchBloc(
                      rabbitsRepository: context.read<IRabbitsRepository>(),
                    ),
          ),
        ],
        child: BlocConsumer<RabbitsListBloc, RabbitsListState>(
          listener: (context, state) {
            if (state is RabbitsListFailure && state.rabbitsGroups.isNotEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'Wystąpił błąd podczas pobierania królików.',
                  ),
                ),
              );
            }
          },
          buildWhen: (previous, current) =>
              !(previous is RabbitsListSuccess &&
                  current is RabbitsListFailure) &&
              !(previous is RabbitsListSuccess &&
                  current is RabbitsListInitial),
          builder: (context, state) {
            late Widget body;

            switch (state) {
              case RabbitsListInitial():
                body = const InitialView();
              case RabbitsListFailure():
                body = FailureView(
                  message: 'Wystąpił błąd podczas pobierania królików.',
                  onPressed: () => context
                      .read<RabbitsListBloc>()
                      .add(const RefreshRabbits()),
                );
              case RabbitsListSuccess():
                body = RabbitsListView(
                  rabbitsGroups: state.rabbitsGroups,
                  hasReachedMax: state.hasReachedMax,
                );
            }

            return Scaffold(
              appBar: AppBar(
                title: const Text('Króliki'),
                actions: [
                  SearchAction(
                    key: const Key('search_action'),
                    onClear: () => context.read<RabbitsSearchBloc>().add(
                          const RabbitsSearchClear(),
                        ),
                    generateResults: (generateContext, query) {
                      context
                          .read<RabbitsSearchBloc>()
                          .add(RabbitsSearchQueryChanged(query));

                      return BlocBuilder<RabbitsSearchBloc, RabbitsSearchState>(
                        bloc: context.read<RabbitsSearchBloc>(),
                        builder: (context, state) {
                          switch (state) {
                            case RabbitsSearchInitial():
                              return Container(
                                key: const Key('search_initial'),
                              );
                            case RabbitsSearchFailure():
                              return const FailureView(
                                message:
                                    'Wystąpił błąd podczas wyszukiwania królików.',
                              );
                            case RabbitsSearchSuccess():
                              return RabbitsSearchView(
                                rabbits: state.rabbits,
                                hasReachedMax: state.hasReachedMax,
                              );
                          }
                        },
                      );
                    },
                  ),
                  IconButton(
                    // TODO: Add filter functionality
                    icon: const Icon(Icons.filter_alt),
                    onPressed: () {
                      showModalBottomSheet(
                        context: context,
                        builder: (context) {
                          return SizedBox(
                              width: double.infinity,
                              child: Center(
                                  child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Text('Tutaj powinny być filtry'),
                                  FilledButton.tonal(
                                    child: const Text('Zamknij'),
                                    onPressed: () => context.pop(),
                                  ),
                                ],
                              )));
                        },
                      );
                    },
                  ),
                ],
              ),
              drawer: drawer,
              body: body,
            );
          },
        ),
      );
}
