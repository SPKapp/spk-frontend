import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:spk_app_frontend/common/views/views.dart';

import 'package:spk_app_frontend/features/users/bloc/user.cubit.dart';
import 'package:spk_app_frontend/features/users/models/models.dart';
import 'package:spk_app_frontend/features/users/repositories/interfaces.dart';
import 'package:spk_app_frontend/features/users/views/views/user.view.dart';

class MyProfilePage extends StatelessWidget {
  const MyProfilePage({
    super.key,
    this.drawer,
    this.userCubit,
  });

  final Widget? drawer;
  final UserCubit Function(BuildContext)? userCubit;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: userCubit ??
          (context) => UserCubit(
                usersRepository: context.read<IUsersRepository>(),
              )..fetchUser(),
      child: BlocBuilder<UserCubit, UserState>(
        builder: (context, state) {
          late final AppBar appBar;
          late final Widget body;

          switch (state) {
            case UserInitial():
              appBar = AppBar();
              body = const InitialView();
            case UserFailure():
              appBar = AppBar();
              body = FailureView(
                message: 'Nie udało się pobrać użytkownika',
                onPressed: () => context.read<UserCubit>().fetchUser(),
              );
            case UserSuccess():
              final roleInfo = RoleInfo(state.user.rolesWithDetails);
              appBar = AppBar(
                actions: [
                  IconButton(
                    key: const Key('editUserButton'),
                    icon: const Icon(Icons.edit),
                    onPressed: () => context.go('/myAccount/edit'),
                  ),
                  PopupMenuButton(
                    key: const Key('userPopupMenu'),
                    itemBuilder: (_) => [
                      PopupMenuItem(
                        key: const Key('changePassword'),
                        onTap: () async {
                          await showModalBottomSheet<bool>(
                              context: context,
                              builder: (_) {
                                return const Text('Not implemented yet');
                              });
                        },
                        child: const Text('Zmień Hasło'),
                      ),
                    ],
                  )
                ],
                title: Text(state.user.fullName),
              );
              body = UserView(
                user: state.user,
                roleInfo: roleInfo,
              );
          }

          return Scaffold(
            drawer: drawer,
            appBar: appBar,
            body: body,
          );
        },
      ),
    );
  }
}
