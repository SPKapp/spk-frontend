import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:spk_app_frontend/common/views/views.dart';

import 'package:spk_app_frontend/features/rabbits/bloc/rabbit_update.cubit.dart';
import 'package:spk_app_frontend/features/rabbits/models/models.dart';
import 'package:spk_app_frontend/features/rabbits/repositories/interfaces.dart';

import 'package:spk_app_frontend/features/users/bloc/users_list.bloc.dart';
import 'package:spk_app_frontend/features/users/models/models.dart';
import 'package:spk_app_frontend/features/users/repositories/interfaces/users.repo.interface.dart';

/// A widget that represents an action to change a volunteer of a rabbit.
class EditVolunteerAction extends StatefulWidget {
  const EditVolunteerAction({
    super.key,
    required this.rabbit,
    this.usersListBloc,
    this.rabbitUpdateCubit,
  });

  final Rabbit rabbit;
  final UsersListBloc Function(BuildContext)? usersListBloc;
  final RabbitUpdateCubit Function(BuildContext)? rabbitUpdateCubit;

  @override
  State<EditVolunteerAction> createState() => _EditVolunteerActionState();
}

class _EditVolunteerActionState extends State<EditVolunteerAction> {
  late Team? _selectedTeam = widget.rabbit.rabbitGroup!.team;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: widget.usersListBloc ??
                (context) => UsersListBloc(
                      usersRepository: context.read<IUsersRepository>(),
                      perPage: 0,
                      regionIds: [widget.rabbit.rabbitGroup!.id],
                    )..add(const FetchUsers()),
          ),
          BlocProvider(
            create: widget.rabbitUpdateCubit ??
                (context) => RabbitUpdateCubit(
                      rabbitsRepository: context.read<IRabbitsRepository>(),
                    ),
          ),
        ],
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Text('Wybierz nowych opiekunów',
                  style: Theme.of(context).textTheme.titleLarge),
            ),
            Expanded(
              child: BlocListener<RabbitUpdateCubit, RabbitUpdateState>(
                listener: (context, state) {
                  switch (state) {
                    case RabbitUpdated():
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Zapisano zmiany'),
                        ),
                      );
                      context.pop(true);
                    case RabbitUpdateFailure():
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Nie udało się zmienić opiekuna'),
                        ),
                      );
                    default:
                  }
                },
                child: BlocBuilder<UsersListBloc, UsersListState>(
                  builder: (context, state) {
                    switch (state) {
                      case UsersListInitial():
                        return const InitialView();
                      case UsersListFailure():
                        return FailureView(
                          message: 'Nie udało się pobrać listy opiekunów',
                          onPressed: () => context
                              .read<UsersListBloc>()
                              .add(const FetchUsers()),
                        );
                      case UsersListSuccess():
                        return Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            DropdownButton<Team>(
                              items: state.teams
                                  .map(
                                    (team) => DropdownMenuItem(
                                      value: team,
                                      child: Text(team.name),
                                    ),
                                  )
                                  .toList(),
                              onChanged: (value) {
                                setState(() {
                                  _selectedTeam = value;
                                });
                              },
                              value: _selectedTeam,
                            ),
                            const SizedBox(height: 20),
                            FilledButton(
                              onPressed: () {
                                if (_selectedTeam == null) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content:
                                          Text('Nie wybrano nowego opiekuna'),
                                    ),
                                  );
                                  context.pop(true);
                                } else if (_selectedTeam !=
                                    widget.rabbit.rabbitGroup!.team!) {
                                  context.read<RabbitUpdateCubit>().changeTeam(
                                        widget.rabbit.rabbitGroup!.id,
                                        _selectedTeam!.id,
                                      );
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Nie zmieniono opiekuna'),
                                    ),
                                  );
                                  context.pop(true);
                                }
                              },
                              child: const Text('Zapisz'),
                            ),
                          ],
                        );
                    }
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
