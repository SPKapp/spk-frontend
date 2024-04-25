import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:spk_app_frontend/features/users/bloc/user_create.cubit.dart';
import 'package:spk_app_frontend/features/users/models/dto.dart';
import 'package:spk_app_frontend/features/users/repositories/interfaces.dart';
import 'package:spk_app_frontend/features/users/views/views/user_modify.view.dart';

/// Represents a page for creating a new user.
///
/// This widget assumes that the [IUsersRepository] is provided above by [RepositoryProvider].
class UserCreatePage extends StatefulWidget {
  const UserCreatePage({
    super.key,
    this.cubitCreate,
  });

  final UserCreateCubit Function(BuildContext)? cubitCreate;

  @override
  State<UserCreatePage> createState() => _UserCreatePageState();
}

class _UserCreatePageState extends State<UserCreatePage> {
  final _formKey = GlobalKey<FormState>();
  final FieldControlers _editControlers = FieldControlers();

  @override
  void dispose() {
    _editControlers.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<UserCreateCubit>(
      create: widget.cubitCreate ??
          (context) => UserCreateCubit(
                usersRepository: context.read<IUsersRepository>(),
              ),
      child: Builder(builder: (context) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Dodaj Użytkownika'),
            actions: [
              _SaveButton(
                key: const Key('saveButton'),
                formKey: _formKey,
                editControlers: _editControlers,
              ),
            ],
          ),
          body: Form(
            key: _formKey,
            child: UserModifyView(
              editControlers: _editControlers,
            ),
          ),
        );
      }),
    );
  }
}

class _SaveButton extends StatelessWidget {
  const _SaveButton({
    super.key,
    required GlobalKey<FormState> formKey,
    required FieldControlers editControlers,
  })  : _formKey = formKey,
        _editControlers = editControlers;

  final GlobalKey<FormState> _formKey;
  final FieldControlers _editControlers;

  @override
  Widget build(BuildContext context) {
    return BlocListener<UserCreateCubit, UserCreateState>(
      listener: (context, state) {
        switch (state) {
          case UserCreated():
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Użytkownik został dodany'),
              ),
            );
            context.pushReplacement('/user/${state.userId}');
            break;
          case UserCreateFailure():
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Nie udało się dodać użytkownika'),
              ),
            );
          default:
        }
      },
      child: IconButton(
        icon: const Icon(Icons.send_rounded),
        onPressed: () {
          if (_formKey.currentState!.validate()) {
            context.read<UserCreateCubit>().createUser(
                  UserCreateDto(
                    firstname: _editControlers.firstnameControler.text,
                    lastname: _editControlers.lastnameControler.text,
                    email: _editControlers.emailControler.text,
                    phone: _editControlers.phoneControler.text,
                  ),
                );
          }
        },
      ),
    );
  }
}
