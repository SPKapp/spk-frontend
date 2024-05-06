import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:spk_app_frontend/features/auth/auth.dart';
import 'package:spk_app_frontend/features/regions/views/views.dart';
import 'package:spk_app_frontend/features/regions/bloc/regions_list.bloc.dart';
import 'package:spk_app_frontend/features/regions/models/models.dart';
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
    this.regionsListBloc,
  });

  final UserCreateCubit Function(BuildContext)? cubitCreate;
  final RegionsListBloc Function(BuildContext)? regionsListBloc;

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
        final currentUser = context.read<AuthCubit>().currentUser;

        if (currentUser.checkRole([Role.admin])) {
          return InjectRegionsList(
            regionsListBloc: widget.regionsListBloc,
            builder: (context, regions) =>
                _buildForm(context, regions: regions),
          );
        } else if (currentUser.managerRegions!.length > 1) {
          return InjectRegionsList(
            regionsListBloc: widget.regionsListBloc,
            regionsIds: currentUser.managerRegions?.map((e) => e.toString()),
            builder: (context, regions) =>
                _buildForm(context, regions: regions),
          );
        } else {
          _editControlers.selectedRegion =
              Region(id: currentUser.managerRegions!.first);
          return Builder(
            builder: (context) => _buildForm(context),
          );
        }
      }),
    );
  }

  void _onSubmit(BuildContext context) {
    if (_formKey.currentState!.validate()) {
      context.read<UserCreateCubit>().createUser(
            UserCreateDto(
              firstname: _editControlers.firstnameControler.text,
              lastname: _editControlers.lastnameControler.text,
              email: _editControlers.emailControler.text,
              phone: _editControlers.phoneControler.text,
              regionId: _editControlers.selectedRegion?.id,
            ),
          );
    }
  }

  Widget _buildForm(BuildContext context, {List<Region>? regions}) {
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
      child: Scaffold(
        appBar: AppBar(
          actions: [
            IconButton(
              key: const Key('saveButton'),
              icon: const Icon(Icons.send_rounded),
              onPressed: () => _onSubmit(context),
            ),
          ],
          title: const Text(
            'Dodaj Użytkownika',
          ),
        ),
        body: Form(
          key: _formKey,
          child: UserModifyView(
            editControlers: _editControlers,
            regions: regions,
          ),
        ),
      ),
    );
  }
}
