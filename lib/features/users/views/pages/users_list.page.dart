import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:spk_app_frontend/common/views/views.dart';
import 'package:spk_app_frontend/common/views/widgets/actions.dart';

import 'package:spk_app_frontend/features/users/bloc/users_list.bloc.dart';
import 'package:spk_app_frontend/features/users/bloc/users_search.bloc.dart';
import 'package:spk_app_frontend/features/users/repositories/interfaces.dart';
import 'package:spk_app_frontend/features/users/views/views/users_list.view.dart';
import 'package:spk_app_frontend/features/users/views/views/users_search_list.view.dart';

/// Represents a page that displays a list of users.
///
/// This widget assumes that the [IUsersRepository] is provided above by [RepositoryProvider].
class UsersListPage extends StatelessWidget {
  const UsersListPage({
    super.key,
    this.drawer,
    this.usersListBloc,
    this.usersSearchBloc,
  });

  final Widget? drawer;
  final UsersListBloc Function(BuildContext)? usersListBloc;
  final UsersSearchBloc Function(BuildContext)? usersSearchBloc;

  @override
  Widget build(BuildContext context) => MultiBlocProvider(
        providers: [
          BlocProvider(
            create: usersListBloc ??
                (context) => UsersListBloc(
                      usersRepository: context.read<IUsersRepository>(),
                    )..add(const FetchUsers()),
          ),
          BlocProvider(
            create: usersSearchBloc ??
                (context) => UsersSearchBloc(
                      usersRepository: context.read<IUsersRepository>(),
                    ),
          ),
        ],
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
                  SearchAction(
                    key: const Key('searchAction'),
                    onClear: () => context.read<UsersSearchBloc>().add(
                          const UsersSearchClear(),
                        ),
                    generateResults: (generateContext, query) =>
                        BlocProvider.value(
                      value: context.read<UsersSearchBloc>()
                        ..add(
                          UsersSearchQueryChanged(query),
                        ),
                      child: BlocBuilder<UsersSearchBloc, UsersSearchState>(
                        builder: (context, state) {
                          switch (state) {
                            case UsersSearchInitial():
                              return Container(
                                key: const Key('searchInitial'),
                              );
                            case UsersSearchFailure():
                              return const FailureView(
                                message:
                                    'Wystąpił błąd podczas wyszukiwania użytkowników.',
                              );
                            case UsersSearchSuccess():
                              return UsersSearchView(
                                users: state.users,
                                hasReachedMax: state.hasReachedMax,
                              );
                          }
                        },
                      ),
                    ),
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
