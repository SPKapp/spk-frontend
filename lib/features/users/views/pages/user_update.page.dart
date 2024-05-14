import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:spk_app_frontend/common/views/views.dart';
import 'package:spk_app_frontend/features/users/bloc/user.cubit.dart';
import 'package:spk_app_frontend/features/users/bloc/user_update.cubit.dart';
import 'package:spk_app_frontend/features/users/models/dto.dart';
import 'package:spk_app_frontend/features/users/models/models.dart';
import 'package:spk_app_frontend/features/users/repositories/interfaces.dart';
import 'package:spk_app_frontend/features/users/views/views/user_modify.view.dart';

class UserUpdatePage extends StatefulWidget {
  const UserUpdatePage({
    super.key,
    this.userId,
    this.updateCubit,
    this.userCubit,
  });

  final String? userId;
  final UserUpdateCubit Function(BuildContext)? updateCubit;
  final UserCubit Function(BuildContext)? userCubit;

  @override
  State<UserUpdatePage> createState() => _UserUpdatePageState();
}

class _UserUpdatePageState extends State<UserUpdatePage> {
  final _formKey = GlobalKey<FormState>();
  final FieldControlers _editControlers = FieldControlers();

  @override
  void dispose() {
    _editControlers.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: widget.updateCubit ??
              (context) => UserUpdateCubit(
                    userId: widget.userId,
                    usersRepository: context.read<IUsersRepository>(),
                  ),
        ),
        BlocProvider(
          create: widget.userCubit ??
              (context) => UserCubit(
                    userId: widget.userId,
                    usersRepository: context.read<IUsersRepository>(),
                  )..fetchUser(),
        ),
      ],
      child: BlocListener<UserUpdateCubit, UserUpdateState>(
        listener: (context, state) {
          switch (state) {
            case UserUpdated():
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Użytkownik został zaktualizowany'),
                ),
              );
              context.pop(true);
              break;
            case UserUpdateFailure():
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Nie udało się zaktualizować użytkownika'),
                ),
              );
              break;
            default:
              break;
          }
        },
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
                _loadData(state.user);
                appBar = AppBar(
                  title: const Text('Edycja użytkownika'),
                  actions: [
                    IconButton(
                      key: const Key('saveButton'),
                      icon: const Icon(Icons.save),
                      onPressed: () => _onSubmit(context, state.user),
                    ),
                  ],
                );
                body = Form(
                  key: _formKey,
                  child: UserModifyView(editControlers: _editControlers),
                );
            }

            return Scaffold(
              appBar: appBar,
              body: body,
            );
          },
        ),
      ),
    );
  }

  void _loadData(User user) {
    _editControlers.firstnameControler.text = user.firstName;
    _editControlers.lastnameControler.text = user.lastName;
    _editControlers.emailControler.text = user.email ?? '';
    _editControlers.phoneControler.text = user.phone ?? '';
  }

  void _onSubmit(BuildContext context, User user) async {
    if (_formKey.currentState!.validate()) {
      final dto = UserUpdateDto(
        id: widget.userId,
        firstName: (user.firstName != _editControlers.firstnameControler.text)
            ? _editControlers.firstnameControler.text
            : null,
        lastName: (user.lastName != _editControlers.lastnameControler.text)
            ? _editControlers.lastnameControler.text
            : null,
        email: (user.email != _editControlers.emailControler.text)
            ? _editControlers.emailControler.text
            : null,
        phone: (user.phone != _editControlers.phoneControler.text)
            ? _editControlers.phoneControler.text
            : null,
      );

      if (dto.hasChanges == false) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Nie wprowadzono zmian'),
          ),
        );
        return;
      }

      if (dto.email != null) {
        final result = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Potwierdzenie zmiany adresu email'),
            content: const Text('Czy na pewno chcesz zmienić adres email?'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(false);
                },
                child: const Text('Nie'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(true);
                },
                child: const Text('Tak'),
              ),
            ],
          ),
        );
        if (result != true) {
          return;
        }
      }

      if (context.mounted) {
        context.read<UserUpdateCubit>().updateUser(dto);
      }
    }
  }
}
