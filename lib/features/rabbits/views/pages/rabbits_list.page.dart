import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:spk_app_frontend/common/views/views.dart';
import 'package:spk_app_frontend/features/auth/auth.dart';

import 'package:spk_app_frontend/features/rabbits/bloc/rabbits_list.bloc.dart';
import 'package:spk_app_frontend/features/rabbits/models/dto.dart';
import 'package:spk_app_frontend/features/rabbits/repositories/interfaces.dart';
import 'package:spk_app_frontend/features/rabbits/views/views/rabbits_list.view.dart';
import 'package:spk_app_frontend/features/rabbits/views/widgets/list_actions.dart';

/// A page that displays a list of rabbits.
///
/// This widget assumes that the [IRabbitsRepository] is provided above by [RepositoryProvider].
class RabbitsListPage extends StatelessWidget {
  const RabbitsListPage({
    super.key,
    this.drawer,
    this.rabbitsListBloc,
    this.volunteerView = true,
  });

  final Widget? drawer;
  final RabbitsListBloc Function(BuildContext)? rabbitsListBloc;
  final bool volunteerView;

  @override
  Widget build(BuildContext context) {
    final teamIds = volunteerView &&
            context.read<AuthCubit>().currentUser.checkRole([Role.volunteer])
        ? [context.read<AuthCubit>().currentUser.teamId!]
        : null;

    final canCreate = context
        .read<AuthCubit>()
        .currentUser
        .checkRole([Role.admin, Role.regionManager]);

    return BlocProvider(
      create: rabbitsListBloc ??
          (context) => RabbitsListBloc(
                rabbitsRepository: context.read<IRabbitsRepository>(),
                args: FindRabbitsArgs(
                  teamsIds: teamIds,
                ),
              )..add(const FetchRabbits()),
      child: BlocConsumer<RabbitsListBloc, RabbitsListState>(
        listener: (context, state) {
          if (state is RabbitsListFailure && state.rabbitGroups.isNotEmpty) {
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
            previous is! RabbitsListSuccess || current is RabbitsListSuccess,
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
                    .add(const RefreshRabbits(null)),
              );
            case RabbitsListSuccess():
              body = RabbitsListView(
                rabbitGroups: state.rabbitGroups,
                hasReachedMax: state.hasReachedMax,
              );
          }

          return Scaffold(
            appBar: AppBar(
              title: Text(volunteerView ? 'Moje Króliki' : 'Króliki'),
              actions: [
                RabbitsSearchAction(
                  key: const Key('searchAction'),
                  args: context.read<RabbitsListBloc>().args,
                ),
                IconButton(
                  key: const Key('filterAction'),
                  icon: const Icon(Icons.filter_alt),
                  onPressed: () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      builder: (_) {
                        return BlocProvider.value(
                          value: context.read<RabbitsListBloc>(),
                          child: RabbitsListFilters(
                            args: context.read<RabbitsListBloc>().args,
                          ),
                        );
                      },
                    );
                  },
                ),
              ],
            ),
            drawer: drawer,
            floatingActionButton: !volunteerView && canCreate
                ? FloatingActionButton(
                    key: const Key('addRabbitButton'),
                    onPressed: () {
                      context.push('/rabbit/add');
                    },
                    child: const Icon(Icons.add),
                  )
                : null,
            body: body,
          );
        },
      ),
    );
  }
}
