import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:spk_app_frontend/common/bloc/interfaces/get_list.bloc.interface.dart';
import 'package:spk_app_frontend/common/views/pages/get_list.page.dart';
import 'package:spk_app_frontend/common/views/widgets/lists/card.widget.dart';
import 'package:spk_app_frontend/features/users/bloc/users_list.bloc.dart';
import 'package:spk_app_frontend/features/users/models/dto.dart';
import 'package:spk_app_frontend/features/users/models/models.dart';
import 'package:spk_app_frontend/features/users/repositories/interfaces.dart';
import 'package:spk_app_frontend/features/users/views/widgets/list_actions.dart';

/// Represents a page that displays a list of users.
///
/// This widget assumes that the [IUsersRepository] is provided above by [RepositoryProvider].
class UsersListPage extends StatelessWidget {
  const UsersListPage({
    super.key,
    this.usersListBloc,
  });

  final UsersListBloc Function(BuildContext)? usersListBloc;

  @override
  Widget build(BuildContext context) => BlocProvider(
        create: usersListBloc ??
            (context) => UsersListBloc(
                  usersRepository: context.read<IUsersRepository>(),
                  args: const FindUsersArgs(),
                )..add(const FetchList()),
        child: Builder(builder: (context) {
          return GetListPage<User, FindUsersArgs, UsersListBloc>(
            title: 'Użytkownicy',
            errorInfo: 'Wystąpił błąd podczas pobierania użytkowników.',
            floatingActionButton: FloatingActionButton(
              key: const Key('addUserButton'),
              onPressed: () => context.push(
                '/user/add',
              ),
              child: const Icon(Icons.add),
            ),
            actions: [
              UsersSearchAction(
                key: const Key('searchAction'),
                args: context.read<UsersListBloc>().args,
              ),
            ],
            filterBuilder: (context, args, callback) => UsersListFilters(
              args: args,
              onFilter: callback,
            ),
            emptyMessage: 'Brak użytkowników.',
            itemBuilder: (context, user) => AppCard(
              child: ListTile(
                leading: const Icon(Icons.person),
                onTap: () => context.push('/user/${user.id}'),
                title: Text(
                  '${user.firstName} ${user.lastName}',
                ),
                subtitle: Text(
                  user.roles?.map((e) => e.displayName).join(', ') ?? '',
                ),
              ),
            ),
          );
        }),
      );
}
