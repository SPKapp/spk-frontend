import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:spk_app_frontend/common/views/views.dart';

import 'package:spk_app_frontend/features/users/bloc/team/teams_list.bloc.dart';
import 'package:spk_app_frontend/features/users/models/dto.dart';
import 'package:spk_app_frontend/features/users/repositories/interfaces.dart';

/// Represents a page that displays a list of users.
///
/// This widget assumes that the [ITeamsRepository] is provided above by [RepositoryProvider].
class TeamsListPage extends StatelessWidget {
  const TeamsListPage({
    super.key,
    this.drawer,
    this.teamsListBloc,
  });

  final Widget? drawer;
  final TeamsListBloc Function(BuildContext)? teamsListBloc;

  @override
  Widget build(BuildContext context) => BlocProvider(
        create: teamsListBloc ??
            (context) => TeamsListBloc(
                  teamsRepository: context.read<ITeamsRepository>(),
                  args: const FindTeamsArgs(),
                )..add(const FetchTeams()),
        child: BlocConsumer<TeamsListBloc, TeamsListState>(
          listener: (context, state) {
            if (state is TeamsListFailure && state.teams.isNotEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'Wystąpił błąd podczas pobierania użytkowników.',
                  ),
                ),
              );
            }
          },
          buildWhen: (previous, current) =>
              previous is! TeamsListSuccess || current is TeamsListSuccess,
          builder: (context, state) {
            late Widget body;

            switch (state) {
              case TeamsListInitial():
                body = const InitialView();
              case TeamsListFailure():
                body = FailureView(
                  message: 'Wystąpił błąd podczas pobierania użytkowników.',
                  onPressed: () => context
                      .read<TeamsListBloc>()
                      .add(const RefreshTeams(null)),
                );
              case TeamsListSuccess():
                // body = UsersListView(
                //   teams: state.teams,
                //   hasReachedMax: state.hasReachedMax,
                // );
                break;
            }

            return Scaffold(
              appBar: AppBar(
                title: const Text('Użytkownicy'),
                // actions: [
                // IconButton(
                //   key: const Key('filterAction'),
                //   icon: const Icon(Icons.filter_alt),
                //   onPressed: () {
                //     showModalBottomSheet(
                //       context: context,
                //       isScrollControlled: true,
                //       builder: (_) {
                //         return BlocProvider.value(
                //           value: context.read<TeamsListBloc>(),
                //           child: UsersListFilters(
                //             args: context.read<TeamsListBloc>().args,
                //           ),
                //         );
                //       },
                //     );
                //   },
                // ),
                // ],
              ),
              drawer: drawer,
              floatingActionButton: FloatingActionButton(
                key: const Key('addUserButton'),
                onPressed: () => context.push(
                  '/user/add',
                ),
                child: const Icon(Icons.add),
              ),
              body: body,
            );
          },
        ),
      );
}
