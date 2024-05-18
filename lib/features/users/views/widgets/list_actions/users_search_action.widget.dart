import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:spk_app_frontend/common/views/widgets/actions.dart';
import 'package:spk_app_frontend/common/views/widgets/actions/search_action.widget.dart';
import 'package:spk_app_frontend/common/views/widgets/lists/card.widget.dart';
import 'package:spk_app_frontend/features/users/bloc/users_search.bloc.dart';
import 'package:spk_app_frontend/features/users/models/dto/find_users.args.dart';
import 'package:spk_app_frontend/features/users/models/models.dart';
import 'package:spk_app_frontend/features/users/repositories/interfaces.dart';

class UsersSearchAction extends StatelessWidget {
  const UsersSearchAction({
    super.key,
    required this.args,
    this.usersSearchBloc,
  });

  final FindUsersArgs Function() args;
  final UsersSearchBloc Function(BuildContext)? usersSearchBloc;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: usersSearchBloc ??
          (context) => UsersSearchBloc(
                usersRepository: context.read<IUsersRepository>(),
                args: args(),
              ),
      child: SearchAction<User, UsersSearchBloc>(
        errorInfo: 'Wystąpił błąd podczas wyszukiwania użytkowników.',
        itemBuilder: (context, user) {
          return AppCard(
            child: TextButton(
              onPressed: () => context.push('/user/${user.id}'),
              child: Text(
                user.fullName,
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
          );
        },
      ),
    );
  }
}
