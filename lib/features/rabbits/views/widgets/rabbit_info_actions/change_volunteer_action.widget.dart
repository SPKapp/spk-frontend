import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:spk_app_frontend/common/views/views.dart';

import 'package:spk_app_frontend/features/rabbits/bloc/rabbit_update.cubit.dart';
import 'package:spk_app_frontend/features/rabbits/models/models.dart';
import 'package:spk_app_frontend/features/rabbits/repositories/interfaces.dart';

import 'package:spk_app_frontend/features/users/bloc/users_list.bloc.dart';
import 'package:spk_app_frontend/features/users/repositories/interfaces/users.repo.interface.dart';

/// A widget that represents an action to change a volunteer of a rabbit.
class ChangeVolunteerAction extends StatefulWidget {
  const ChangeVolunteerAction({
    super.key,
    required this.rabbit,
    this.usersListBloc,
    this.rabbitUpdateCubit,
  });

  final Rabbit rabbit;
  final UsersListBloc Function(BuildContext)? usersListBloc;
  final RabbitUpdateCubit Function(BuildContext)? rabbitUpdateCubit;

  @override
  State<ChangeVolunteerAction> createState() => _ChangeVolunteerActionState();
}

class _ChangeVolunteerActionState extends State<ChangeVolunteerAction> {
  late int? _selectedTeamId = widget.rabbit.rabbitGroup!.team?.id;

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
                      regionsIds: [widget.rabbit.rabbitGroup!.region!.id],
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
              child: Text(
                'Wybierz nowych opiekunów',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleLarge,
              ),
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
                            DropdownButton<int>(
                              items: state.teams
                                  .map(
                                    (team) => DropdownMenuItem(
                                      value: team.id,
                                      child: Text(team.name),
                                    ),
                                  )
                                  .toList(),
                              onChanged: (value) {
                                setState(() {
                                  _selectedTeamId = value;
                                });
                              },
                              value: _selectedTeamId,
                            ),
                            const SizedBox(height: 20),
                            FilledButton(
                              onPressed: () {
                                if (_selectedTeamId == null) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content:
                                          Text('Nie wybrano nowego opiekuna'),
                                    ),
                                  );
                                  context.pop();
                                } else if (_selectedTeamId !=
                                    widget.rabbit.rabbitGroup!.team!.id) {
                                  context.read<RabbitUpdateCubit>().changeTeam(
                                        widget.rabbit.rabbitGroup!.id,
                                        _selectedTeamId!,
                                      );
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Nie zmieniono opiekuna'),
                                    ),
                                  );
                                  context.pop();
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
