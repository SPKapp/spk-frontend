import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spk_app_frontend/common/bloc/interfaces/update.cubit.interface.dart';

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
      child: BlocListener<UserPermissionsCubit, UpdateState>(
        listener: (context, state) {
          switch (state) {
            case UpdateSuccess():
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
            case UpdateFailure():
              late final String message;
              switch (state.code) {
                case 'active-groups':
                  message =
                      'Nie można dezaktywować użytkownika, jest on ostatnim członkiem zespołu posiadającego przypisane aktywne króliki.';
                  break;
                case 'user-not-found':
                  message = 'Nie znaleziono użytkownika';
                  break;
                case 'user-can-not-deactivate-himself':
                  message = 'Nie można dezaktywować samego siebie';
                  break;
                default:
                  message = isActive
                      ? 'Nie udało się dezaktywować użytkownika'
                      : 'Nie udało się aktywować użytkownika';
              }

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  duration: const Duration(seconds: 5),
                  content: Text(
                    message,
                    textAlign: TextAlign.center,
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
