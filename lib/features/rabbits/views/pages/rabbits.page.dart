import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:spk_app_frontend/features/rabbits/bloc/rabbits.bloc.dart';
import 'package:spk_app_frontend/features/rabbits/repositories/interfaces.dart';
import 'package:spk_app_frontend/features/rabbits/views/views/rabbits_list.view.dart';

class RabbitsPage extends StatelessWidget {
  const RabbitsPage({
    super.key,
    required this.drawer,
  });

  final Widget? drawer;

  @override
  Widget build(BuildContext context) => BlocProvider(
        create: (context) => RabbitsBloc(
          rabbitsRepository: context.read<IRabbitsRepository>(),
          queryType: RabbitsQueryType.all,
        )..add(const FeatchRabbits()),
        child: BlocBuilder<RabbitsBloc, RabbitsState>(
          builder: (context, state) {
            late Widget body;

            switch (state) {
              case RabbitsInitial():
                body = const Center(child: CircularProgressIndicator());
              case RabbitsFailure():
                body = const Center(child: Text('Failed to fetch rabbits'));
              case RabbitsSuccess():
                body = RabbitsListView(
                  rabbitsGroups: state.rabbitsGroups,
                  hasReachedMax: state.hasReachedMax,
                );
            }

            return Scaffold(
              appBar: AppBar(
                title: const Text('Króliki'),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.search),
                    onPressed: () {
                      // showSearch(
                      //   context: context,
                      //   delegate: null,
                      // );
                      showModalBottomSheet(
                        context: context,
                        builder: (context) {
                          return SizedBox(
                              width: double.infinity,
                              child: Center(
                                  child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Text('Tutaj powinna być wyszukiwarka'),
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
                  IconButton(
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
