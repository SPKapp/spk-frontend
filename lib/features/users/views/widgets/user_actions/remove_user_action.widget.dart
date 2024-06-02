import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:spk_app_frontend/common/bloc/interfaces/update.cubit.interface.dart';

import 'package:spk_app_frontend/features/users/bloc/user_update.cubit.dart';
import 'package:spk_app_frontend/features/users/repositories/interfaces.dart';

class RemoveUserAction extends StatelessWidget {
  const RemoveUserAction({
    super.key,
    required this.userId,
    this.userUpdateCubit,
  });

  final String userId;
  final UserUpdateCubit Function(BuildContext)? userUpdateCubit;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: userUpdateCubit ??
          (context) => UserUpdateCubit(
                userId: userId,
                usersRepository: context.read<IUsersRepository>(),
              ),
      child: BlocListener<UserUpdateCubit, UpdateState>(
        listener: (context, state) {
          switch (state) {
            case UpdateSuccess():
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'Użytkownik został usunięty.',
                    textAlign: TextAlign.center,
                  ),
                ),
              );
              context.pop(true);
              break;
            case UpdateFailure state:
              late final String message;
              switch (state.code) {
                case 'user-not-found':
                  message = 'Nie znaleziono użytkownika.';
                  break;
                case 'user-active':
                  message = 'Nie można usunąć aktywnego użytkownika.';
                  break;
                default:
                  message = 'Wystąpił błąd podczas usuwania użytkownika.';
                  break;
              }

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    message,
                    textAlign: TextAlign.center,
                  ),
                ),
              );
              context.pop(false);
              break;
            default:
              break;
          }
        },
        child: Builder(builder: (context) {
          return Column(
            children: [
              const Text(
                'Czy na pewno chcesz usunąć użytkownika?',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              const Text(
                  'Spowoduje to usunięcie wszystkich danych użytkownika, w tym jego uprawnień. Operacji tej nie można cofnąć.',
                  textAlign: TextAlign.center),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () {
                  context.read<UserUpdateCubit>().removeUser();
                },
                child: const Text('Usuń'),
              ),
            ],
          );
        }),
      ),
    );
  }
}
