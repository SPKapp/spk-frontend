import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:spk_app_frontend/features/users/bloc/user_actions/user_permissions.cubit.dart';
import 'package:spk_app_frontend/features/users/repositories/interfaces.dart';

class DeactivateUserAction extends StatelessWidget {
  const DeactivateUserAction({
    super.key,
    required this.userId,
    required this.isActive,
    this.userPermissionsCubit,
  });

  final String userId;
  final bool isActive;
  final UserPermissionsCubit Function(BuildContext)? userPermissionsCubit;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: userPermissionsCubit ??
          (context) => UserPermissionsCubit(
                context.read<IPermissionsRepository>(),
                userId,
              ),
      child: BlocListener<UserPermissionsCubit, UserPermissionsState>(
        listener: (context, state) {
          switch (state) {
            case UserPermissionsSuccess():
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    isActive
                        ? 'Użytkownik został dezaktywowany'
                        : 'Użytkownik został aktywowany',
                  ),
                ),
              );
              Navigator.of(context).pop(true);
            case UserPermissionsFailure():
              // TODO: Add reason of failure
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    isActive
                        ? 'Nie udało się dezaktywować użytkownika'
                        : 'Nie udało się aktywować użytkownika',
                  ),
                ),
              );
              Navigator.of(context).pop(false);
            default:
          }
        },
        child: Builder(builder: (context) {
          return AlertDialog(
            title: Text(
              isActive
                  ? 'Czy na pewno chcesz dezaktywować użytkownika?'
                  : 'Czy na pewno chcesz aktywować użytkownika?',
              textAlign: TextAlign.center,
            ),
            content: Text(
              isActive
                  ? 'Spowoduje to dezaktywację użytkownika, co uniemożliwi mu logowanie do aplikacji.'
                  : 'Spowoduje to aktywację użytkownika, co umożliwi mu logowanie do aplikacji.',
              textAlign: TextAlign.center,
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Anuluj'),
              ),
              TextButton(
                onPressed: () {
                  if (isActive) {
                    context.read<UserPermissionsCubit>().deactivateUser();
                  } else {
                    context.read<UserPermissionsCubit>().activateUser();
                  }
                },
                child: Text(isActive ? 'Dezaktywuj' : 'Aktywuj'),
              ),
            ],
          );
        }),
      ),
    );
  }
}
