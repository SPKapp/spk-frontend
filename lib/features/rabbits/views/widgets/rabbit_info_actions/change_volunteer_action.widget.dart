import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:spk_app_frontend/common/bloc/interfaces/update.cubit.interface.dart';

import 'package:spk_app_frontend/common/views/views.dart';

import 'package:spk_app_frontend/features/rabbits/bloc/rabbit_update.cubit.dart';
import 'package:spk_app_frontend/features/rabbits/models/models.dart';
import 'package:spk_app_frontend/features/rabbits/repositories/interfaces.dart';
import 'package:spk_app_frontend/features/users/bloc/team/teams_list.bloc.dart';
import 'package:spk_app_frontend/features/users/models/dto.dart';
import 'package:spk_app_frontend/features/users/models/models.dart';
import 'package:spk_app_frontend/features/users/repositories/interfaces.dart';

/// A widget that represents an action to change a volunteer of a rabbit.
class ChangeVolunteerAction extends StatefulWidget {
  const ChangeVolunteerAction({
    super.key,
    required this.rabbit,
    this.teamsListBloc,
    this.rabbitUpdateCubit,
  });

  final Rabbit rabbit;
  final TeamsListBloc Function(BuildContext)? teamsListBloc;
  final RabbitUpdateCubit Function(BuildContext)? rabbitUpdateCubit;

  @override
  State<ChangeVolunteerAction> createState() => _ChangeVolunteerActionState();
}

class _ChangeVolunteerActionState extends State<ChangeVolunteerAction> {
  late Team? _selectedTeam = widget.rabbit.rabbitGroup!.team;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: widget.teamsListBloc ??
              (context) => TeamsListBloc(
                    teamsRepository: context.read<ITeamsRepository>(),
                    args: FindTeamsArgs(
                      limit: 0,
                      regionsIds: [widget.rabbit.rabbitGroup!.region!.id],
                    ),
                  )..add(const FetchTeams()),
        ),
        BlocProvider(
          create: widget.rabbitUpdateCubit ??
              (context) => RabbitUpdateCubit(
                    rabbitsRepository: context.read<IRabbitsRepository>(),
                  ),
        ),
      ],
      child: BlocListener<RabbitUpdateCubit, UpdateState>(
        listener: (context, state) {
          switch (state) {
            case UpdateSuccess():
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Zapisano zmiany'),
                ),
              );
              context.pop(true);
            case UpdateFailure():
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Nie udało się zmienić opiekuna'),
                ),
              );
            default:
          }
        },
        child: BlocBuilder<TeamsListBloc, TeamsListState>(
          builder: (context, state) {
            switch (state) {
              case TeamsListInitial():
                return const InitialView();
              case TeamsListFailure():
                return FailureView(
                  message: 'Nie udało się pobrać listy opiekunów',
                  onPressed: () =>
                      context.read<TeamsListBloc>().add(const FetchTeams()),
                );
              case TeamsListSuccess():
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
                              content: Text('Nie wybrano nowego opiekuna'),
                            ),
                          );
                          context.pop();
                        } else if (_selectedTeam !=
                            widget.rabbit.rabbitGroup!.team) {
                          context.read<RabbitUpdateCubit>().changeTeam(
                                widget.rabbit.rabbitGroup!.id.toString(),
                                _selectedTeam!.id,
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
    );
  }
}
