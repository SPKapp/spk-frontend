import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';

import 'package:spk_app_frontend/features/auth/bloc/change_password.cubit.dart';

class ChangePasswordAction extends StatefulWidget {
  const ChangePasswordAction({
    super.key,
    this.changePasswordCubit,
  });

  final ChangePasswordCubit Function(BuildContext)? changePasswordCubit;

  @override
  State<ChangePasswordAction> createState() => _ChangePasswordActionState();
}

class _ChangePasswordActionState extends State<ChangePasswordAction> {
  final oldPasswordController = TextEditingController();
  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  String? oldPasswordError;
  String? newPasswordError;
  String? confirmPasswordError;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: widget.changePasswordCubit ?? (context) => ChangePasswordCubit(),
      child: BlocListener<ChangePasswordCubit, PasswordChangeState>(
        listener: (context, state) {
          switch (state) {
            case PasswordChanged():
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Hasło zostało zmienione'),
                ),
              );
              context.pop();
              break;
            case PasswordChangeFailed():
              switch (state.code) {
                case 'wrong-password':
                  setState(() {
                    oldPasswordError = 'Nieprawidłowe hasło';
                  });
                  break;
                case 'weak-password':
                  setState(() {
                    newPasswordError = 'Hasło zbyt słabe';
                  });
                  break;
                default:
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Nie udało się zmienić hasła'),
                    ),
                  );
              }
              break;
            default:
          }
        },
        child: Builder(builder: (context) {
          return FractionallySizedBox(
            heightFactor: 0.6,
            widthFactor: 1.0,
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        'Zmiana hasła',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextField(
                        key: const Key('oldPasswordField'),
                        controller: oldPasswordController,
                        obscureText: true,
                        decoration: InputDecoration(
                          labelText: 'Stare Hasło',
                          border: const OutlineInputBorder(),
                          prefixIcon: const Icon(FontAwesomeIcons.lock),
                          errorText: oldPasswordError,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextField(
                        key: const Key('newPasswordField'),
                        controller: newPasswordController,
                        obscureText: true,
                        decoration: InputDecoration(
                          labelText: 'Nowe Hasło',
                          border: const OutlineInputBorder(),
                          prefixIcon: const Icon(FontAwesomeIcons.lock),
                          errorText: newPasswordError,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextField(
                        key: const Key('confirmPasswordField'),
                        controller: confirmPasswordController,
                        obscureText: true,
                        decoration: InputDecoration(
                          labelText: 'Powtórz Hasło',
                          border: const OutlineInputBorder(),
                          prefixIcon: const Icon(FontAwesomeIcons.lock),
                          errorText: confirmPasswordError,
                        ),
                      ),
                    ),
                    FilledButton.tonal(
                      onPressed: () {
                        setState(() {
                          oldPasswordError = null;
                          newPasswordError = null;
                          confirmPasswordError = null;
                        });

                        bool error = false;

                        final passwordsMatch = newPasswordController.text ==
                            confirmPasswordController.text;

                        if (newPasswordController.text.length < 8) {
                          setState(() {
                            newPasswordError = 'Hasło zbyt krótkie';
                          });
                          error = true;
                        }

                        if (!passwordsMatch) {
                          setState(() {
                            confirmPasswordError = 'Hasła nie pasują do siebie';
                          });
                          error = true;
                        }

                        if (error) {
                          return;
                        }

                        if (oldPasswordController.text.isEmpty ||
                            newPasswordController.text.isEmpty ||
                            confirmPasswordController.text.isEmpty ||
                            !passwordsMatch) {
                          return;
                        }

                        context.read<ChangePasswordCubit>().changePassword(
                            oldPasswordController.text,
                            newPasswordController.text);
                      },
                      child: const Text('Zapisz'),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
