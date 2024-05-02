import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:spk_app_frontend/common/views/views.dart';

import 'package:spk_app_frontend/features/users/bloc/users_list.bloc.dart';
import 'package:spk_app_frontend/features/users/models/dto.dart';
import 'package:spk_app_frontend/features/users/repositories/interfaces.dart';
import 'package:spk_app_frontend/features/users/views/views/users_list.view.dart';
import 'package:spk_app_frontend/features/users/views/widgets/list_actions.dart';

/// Represents a page that displays a list of users.
///
/// This widget assumes that the [IUsersRepository] is provided above by [RepositoryProvider].
class UsersListPage extends StatelessWidget {
  const UsersListPage({
    super.key,
    this.drawer,
    this.usersListBloc,
  });

  final Widget? drawer;
  final UsersListBloc Function(BuildContext)? usersListBloc;

  @override
  Widget build(BuildContext context) => BlocProvider(
        create: usersListBloc ??
            (context) => UsersListBloc(
                  usersRepository: context.read<IUsersRepository>(),
                  args: const FindUsersArgs(),
                )..add(const FetchUsers()),
        child: BlocConsumer<UsersListBloc, UsersListState>(
          listener: (context, state) {
            if (state is UsersListFailure && state.teams.isNotEmpty) {
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
              previous is! UsersListSuccess || current is UsersListSuccess,
          builder: (context, state) {
            late Widget body;

            switch (state) {
              case UsersListInitial():
                body = const InitialView();
              case UsersListFailure():
                body = FailureView(
                  message: 'Wystąpił błąd podczas pobierania użytkowników.',
                  onPressed: () => context
                      .read<UsersListBloc>()
                      .add(const RefreshUsers(null)),
                );
              case UsersListSuccess():
                body = UsersListView(
                  teams: state.teams,
                  hasReachedMax: state.hasReachedMax,
                );
                break;
            }

            return Scaffold(
              appBar: AppBar(
                title: const Text('Użytkownicy'),
                actions: [
                  UsersSearchAction(
                    key: const Key('searchAction'),
                    args: context.read<UsersListBloc>().args,
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
                            value: context.read<UsersListBloc>(),
                            child: UsersListFilters(
                              args: context.read<UsersListBloc>().args,
                            ),
                          );
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
