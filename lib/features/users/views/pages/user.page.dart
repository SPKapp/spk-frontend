import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:spk_app_frontend/common/views/pages/get_one.page.dart';
import 'package:spk_app_frontend/common/views/widgets/actions.dart';
import 'package:spk_app_frontend/features/auth/auth.dart';
import 'package:spk_app_frontend/features/users/bloc/user.cubit.dart';
import 'package:spk_app_frontend/features/users/models/models.dart';
import 'package:spk_app_frontend/features/users/repositories/interfaces.dart';
import 'package:spk_app_frontend/features/users/views/views/user.view.dart';
import 'package:spk_app_frontend/features/users/views/widgets/user_actions.dart';

class UserPage extends StatelessWidget {
  const UserPage({
    super.key,
    required this.userId,
    this.userCubit,
  });

  final String userId;
  final UserCubit Function(BuildContext)? userCubit;

  @override
  Widget build(BuildContext context) {
    final currentUser = context.read<AuthCubit>().currentUser;

    return BlocProvider(
      create: userCubit ??
          (context) => UserCubit(
                userId: userId,
                usersRepository: context.read<IUsersRepository>(),
              )..fetch(),
      child: GetOnePage<User, UserCubit>(
        defaultTitle: 'Użytkownik',
        titleBuilder: (context, user) => user.fullName,
        errorInfo: 'Nie udało się pobrać użytkownika',
        actionsBuilder: (context, user) {
          final roleInfo = RoleInfo(user.rolesWithDetails);
          return [
            if (user.active == true)
              IconButton(
                  key: const Key('editUser'),
                  icon: const Icon(Icons.edit),
                  onPressed: () async {
                    final result = await context.push('/user/${user.id}/edit');

                    if (result == true && context.mounted) {
                      context.read<UserCubit>().fetch();
                    }
                  }),
            PopupMenuButton(
              key: const Key('userPopupMenu'),
              itemBuilder: (_) => [
                if (user.active == true)
                  PopupMenuItem(
                    key: const Key('addRole'),
                    onTap: () async {
                      final result = await showModalBottomSheet<bool>(
                          context: context,
                          isScrollControlled: true,
                          builder: (_) {
                            return AddRoleAction(
                              roleInfo: roleInfo,
                              userId: user.id.toString(),
                            );
                          });
                      if (result == true && context.mounted) {
                        context.read<UserCubit>().fetch();
                      }
                    },
                    child: const Text('Dodaj rolę'),
                  ),
                PopupMenuItem(
                  key: const Key('removeRole'),
                  onTap: () async {
                    final result = await showModalBottomSheet<bool>(
                        context: context,
                        isScrollControlled: true,
                        builder: (_) {
                          return RemoveRoleAction(
                            roleInfo: roleInfo,
                            userId: user.id.toString(),
                          );
                        });
                    if (result == true && context.mounted) {
                      context.read<UserCubit>().fetch();
                    }
                  },
                  child: const Text('Usuń rolę'),
                ),
                if (user.active == true &&
                    (currentUser.checkRole([Role.admin]) ||
                        (currentUser.managerRegions?.isNotEmpty == true &&
                            currentUser.managerRegions!.length > 1)))
                  PopupMenuItem(
                    key: const Key('changeRegion'),
                    onTap: () async {
                      final result = await showModalBottomSheet<bool>(
                          context: context,
                          builder: (_) {
                            return const Text('Not implemented yet');
                          });
                      if (result == true && context.mounted) {
                        context.read<UserCubit>().fetch();
                      }
                    },
                    child: const Text('Zmień region'),
                  ),
                PopupMenuItem(
                  key: const Key('deactivateUser'),
                  onTap: () async {
                    final result = await showDialog<bool>(
                        context: context,
                        builder: (_) {
                          return DeactivateUserAction(
                            userId: user.id.toString(),
                            isActive: user.active ?? false,
                          );
                        });
                    if (result == true && context.mounted) {
                      context.read<UserCubit>().fetch();
                    }
                  },
                  child: Text(user.active == true ? 'Dezaktywuj' : 'Aktywuj'),
                ),
                if (user.active == false)
                  PopupMenuItem(
                    key: const Key('deleteUser'),
                    onTap: () async {
                      await showModalMyBottomSheet<bool>(
                          context: context,
                          title: 'Usuń użytkownika',
                          builder: (_) => RemoveUserAction(
                                userId: user.id,
                              ),
                          onClosing: (result) {
                            if (context.canPop()) {
                              context.pop({
                                'deleted': true,
                              });
                            } else {
                              context.read<UserCubit>().fetch();
                            }
                          });
                    },
                    child: const Text('Usuń'),
                  ),
              ],
            ),
          ];
        },
        builder: (context, user) => UserView(
          user: user,
          roleInfo: RoleInfo(user.rolesWithDetails),
        ),
      ),
    );
  }
}
