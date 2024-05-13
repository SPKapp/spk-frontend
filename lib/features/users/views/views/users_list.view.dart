import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:spk_app_frontend/common/views/views.dart';
import 'package:spk_app_frontend/common/views/widgets/lists/card.widget.dart';
import 'package:spk_app_frontend/features/users/bloc/users_list.bloc.dart';
import 'package:spk_app_frontend/features/users/models/models.dart';

/// A widget that displays a scrollable list of users.
///
/// This widget assumes that the [UsersListBloc] is already provided above in the widget tree.
/// If [users] is empty, it displays a message "Brak użytkowników.".
/// If [hasReachedMax] is false, it displays a [CircularProgressIndicator] at the end of the list.
class UsersListView extends StatelessWidget {
  const UsersListView({
    super.key,
    required this.users,
    required this.hasReachedMax,
  });

  final List<User> users;
  final bool hasReachedMax;

  @override
  Widget build(BuildContext context) {
    return AppListView(
      items: users,
      hasReachedMax: hasReachedMax,
      onRefresh: () async {
        // skip initial state
        Future bloc = context.read<UsersListBloc>().stream.skip(1).first;
        context.read<UsersListBloc>().add(const RefreshUsers(null));
        return bloc;
      },
      onFetch: () {
        context.read<UsersListBloc>().add(const FetchUsers());
      },
      emptyMessage: 'Brak użytkowników.',
      itemBuilder: (dynamic user) => AppCard(
          child: ListTile(
        leading: const Icon(Icons.person),
        onTap: () => context.push('/user/${user.id}'),
        title: Text(
          '${user.firstName} ${user.lastName}',
        ),
        subtitle:
            Text(user.roles?.map((e) => e.toHumanReadable()).join(', ') ?? ''),
      )),
    );
  }
}
