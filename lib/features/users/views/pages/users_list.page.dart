import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:spk_app_frontend/common/views/views.dart';

import 'package:spk_app_frontend/features/users/bloc/users_list.bloc.dart';
import 'package:spk_app_frontend/features/users/repositories/interfaces.dart';
import 'package:spk_app_frontend/features/users/views/views/users_list.view.dart';

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
              !(previous is UsersListSuccess && current is UsersListFailure) &&
              !(previous is UsersListSuccess && current is UsersListInitial),
          builder: (context, state) {
            late Widget body;

            switch (state) {
              case UsersListInitial():
                body = const InitialView();
              case UsersListFailure():
                body = FailureView(
                  message: 'Wystąpił błąd podczas pobierania użytkowników.',
                  onPressed: () =>
                      context.read<UsersListBloc>().add(const RefreshUsers()),
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
                  IconButton(
                    // TODO: Add search functionality
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
