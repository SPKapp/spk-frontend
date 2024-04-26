import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:spk_app_frontend/common/views/views.dart';
import 'package:spk_app_frontend/common/views/widgets/actions.dart';
import 'package:spk_app_frontend/common/views/widgets/lists/card.widget.dart';
import 'package:spk_app_frontend/features/rabbits/bloc/rabbits_search.bloc.dart';
import 'package:spk_app_frontend/features/rabbits/models/dto.dart';
import 'package:spk_app_frontend/features/rabbits/models/models.dart';
import 'package:spk_app_frontend/features/rabbits/repositories/interfaces.dart';

class RabbitsSearchAction extends StatelessWidget {
  const RabbitsSearchAction({
    super.key,
    required this.args,
    this.rabbitsSearchBloc,
  });

  final FindRabbitsArgs args;
  final RabbitsSearchBloc Function(BuildContext)? rabbitsSearchBloc;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: rabbitsSearchBloc ??
          (context) => RabbitsSearchBloc(
                rabbitsRepository: context.read<IRabbitsRepository>(),
                args: args,
              ),
      child: Builder(builder: (context) {
        return SearchAction(
          onClear: () => context.read<RabbitsSearchBloc>().add(
                const RabbitsSearchClear(),
              ),
          generateResults: (generateContext, query) {
            return BlocProvider.value(
              value: context.read<RabbitsSearchBloc>(),
              child: BlocBuilder<RabbitsSearchBloc, RabbitsSearchState>(
                  builder: (context, state) {
                if (state.query != query) {
                  context
                      .read<RabbitsSearchBloc>()
                      .add(RabbitsSearchRefresh(query));
                }
                switch (state) {
                  case RabbitsSearchInitial():
                    return Container(
                      key: const Key('searchInitial'),
                    );
                  case RabbitsSearchFailure():
                    return const FailureView(
                      message: 'Wystąpił błąd podczas wyszukiwania królików.',
                    );
                  case RabbitsSearchSuccess():
                    return AppListView<Rabbit>(
                      items: state.rabbits,
                      hasReachedMax: state.hasReachedMax,
                      onRefresh: () async {},
                      onFetch: () {
                        context
                            .read<RabbitsSearchBloc>()
                            .add(const RabbitsSearchFetch());
                      },
                      itemBuilder: (dynamic rabbit) {
                        return AppCard(
                          child: TextButton(
                            onPressed: () => context
                                .push('/rabbit/${(rabbit as Rabbit).id}'),
                            child: Text(
                              rabbit.name,
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                          ),
                        );
                      },
                    );
                }
              }),
            );
          },
        );
      }),
    );
  }
}
