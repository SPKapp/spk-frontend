import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:spk_app_frontend/common/views/pages/get_one.page.dart';
import 'package:spk_app_frontend/common/views/widgets/lists/card.widget.dart';
import 'package:spk_app_frontend/features/auth/auth.dart';
import 'package:spk_app_frontend/features/auth/bloc/send_verification_mail.cubit.dart';

import 'package:spk_app_frontend/features/auth/views/widgets/change_password.widget.dart';
import 'package:spk_app_frontend/features/users/bloc/user.cubit.dart';
import 'package:spk_app_frontend/features/users/models/models.dart';
import 'package:spk_app_frontend/features/users/repositories/interfaces.dart';
import 'package:spk_app_frontend/features/users/views/views/user.view.dart';

class MyProfilePage extends StatelessWidget {
  const MyProfilePage({
    super.key,
    this.userCubit,
    this.sendVerificationMailCubit,
  });

  final UserCubit Function(BuildContext)? userCubit;
  final SendVerificationMailCubit Function(BuildContext)?
      sendVerificationMailCubit;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: userCubit ??
          (context) => UserCubit(
                usersRepository: context.read<IUsersRepository>(),
              )..fetch(),
      child: GetOnePage<User, UserCubit>(
        defaultTitle: 'Mój Profil',
        titleBuilder: (context, user) => user.fullName,
        errorInfo: 'Nie udało się pobrać użytkownika',
        actionsBuilder: (context, data) {
          return [
            IconButton(
                key: const Key('editUserButton'),
                icon: const Icon(Icons.edit),
                onPressed: () async {
                  final result = await context.push('/myProfile/edit');

                  if (result == true && context.mounted) {
                    context.read<UserCubit>().fetch();
                  }
                }),
            PopupMenuButton(
              key: const Key('userPopupMenu'),
              itemBuilder: (_) => [
                PopupMenuItem(
                  key: const Key('changePassword'),
                  onTap: () async {
                    await showModalBottomSheet<bool>(
                      context: context,
                      isScrollControlled: true,
                      builder: (_) => const ChangePasswordAction(),
                    );
                  },
                  child: const Text('Zmień Hasło'),
                ),
              ],
            )
          ];
        },
        builder: (context, user) => UserView(
          user: user,
          roleInfo: RoleInfo(user.rolesWithDetails),
          errorWidget:
              context.read<AuthCubit>().currentUser.emailVerified == false
                  ? buildEmailVerificationError(context)
                  : null,
        ),
      ),
    );
  }

  Widget buildEmailVerificationError(BuildContext context) {
    return BlocProvider(
      create:
          sendVerificationMailCubit ?? (context) => SendVerificationMailCubit(),
      child: BlocListener<SendVerificationMailCubit, SendVerificationMailState>(
        listener: (context, state) {
          switch (state) {
            case SendVerificationMailSuccess():
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Wysłano link weryfikacyjny'),
                ),
              );
              break;
            case SendVerificationMailFailure():
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Nie udało się wysłać linku weryfikacyjnego'),
                ),
              );
              break;
            default:
              break;
          }
        },
        child: Builder(builder: (context) {
          return AppCard(
            key: const Key('emailVerificationError'),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      'Adres email nie został zweryfikowany',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Colors.red,
                          ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      'Naciśnij przycisk poniżej, aby wysłać link weryfikacyjny',
                      textAlign: TextAlign.center,
                    ),
                  ),
                  FilledButton.tonal(
                    onPressed: () async {
                      context
                          .read<SendVerificationMailCubit>()
                          .sendVerificationMail();
                    },
                    child: const Text('Wyślij link weryfikacyjny'),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}
