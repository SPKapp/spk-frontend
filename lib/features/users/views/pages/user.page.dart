import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:spk_app_frontend/common/views/views.dart';
import 'package:spk_app_frontend/features/auth/auth.dart';
import 'package:spk_app_frontend/features/users/bloc/user.cubit.dart';
import 'package:spk_app_frontend/features/users/models/models.dart';
import 'package:spk_app_frontend/features/users/repositories/interfaces.dart';
import 'package:spk_app_frontend/features/users/views/widgets/user_actions.dart';
import 'package:spk_app_frontend/features/users/views/widgets/user_view/roles_card.widget.dart';

// TODO: Implement This
class UserPage extends StatelessWidget {
  const UserPage({
    super.key,
    required this.userId,
    this.userCubit,
  });

  final int userId;
  final UserCubit Function(BuildContext)? userCubit;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: userCubit ??
          (context) => UserCubit(
                userId: userId,
                usersRepository: context.read<IUsersRepository>(),
              )..fetchUser(),
      child: BlocBuilder<UserCubit, UserState>(
        builder: (context, state) {
          final currentUser = context.read<AuthCubit>().currentUser;
          late AppBar appBar;
          late Widget body;

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
                    icon: const Icon(Icons.edit),
                    onPressed: () => context.go('/users/$userId/edit'),
                  ),
                  PopupMenuButton(
                    key: const Key('userPopupMenu'),
                    itemBuilder: (_) => [
                      if (state.user.active == true)
                        PopupMenuItem(
                          key: const Key('addRole'),
                          onTap: () async {
                            final result = await showModalBottomSheet<bool>(
                                context: context,
                                isScrollControlled: true,
                                builder: (_) {
                                  return AddRoleAction(
                                    roleInfo: roleInfo,
                                    userId: state.user.id.toString(),
                                  );
                                });
                            if (result != null && result && context.mounted) {
                              context.read<UserCubit>().fetchUser();
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
                                  userId: state.user.id.toString(),
                                );
                              });
                          if (result != null && result && context.mounted) {
                            context.read<UserCubit>().fetchUser();
                          }
                        },
                        child: const Text('Usuń rolę'),
                      ),
                      if (currentUser.checkRole([Role.admin]) ||
                          (currentUser.managerRegions?.isNotEmpty == true &&
                              currentUser.managerRegions!.length > 1))
                        PopupMenuItem(
                          onTap: () async {
                            final result = await showModalBottomSheet<bool>(
                                context: context,
                                builder: (_) {
                                  return const Text('Not implemented yet');
                                });
                            if (result != null && result && context.mounted) {
                              context.read<UserCubit>().fetchUser();
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
                                  userId: state.user.id.toString(),
                                  isActive: state.user.active ?? false,
                                );
                              });
                          if (result != null && result && context.mounted) {
                            context.read<UserCubit>().fetchUser();
                          }
                        },
                        child: Text(state.user.active == true
                            ? 'Dezaktywuj'
                            : 'Aktywuj'),
                      ),
                      PopupMenuItem(
                        onTap: () async {
                          await showModalBottomSheet<bool>(
                              context: context,
                              builder: (_) {
                                return const Text('Not implemented yet');
                              });
                        },
                        child: const Text('Usuń'),
                      ),
                    ],
                  )
                ],
                title: Text(state.user.fullName),
              );
              body = Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(state.user.toString()),
                  const SizedBox(height: 16),
                  RolesCard(roles: state.user.rolesWithDetails),
                ],
              );
          }

          return Scaffold(
            appBar: appBar,
            body: body,
          );
        },
      ),
    );
  }
}