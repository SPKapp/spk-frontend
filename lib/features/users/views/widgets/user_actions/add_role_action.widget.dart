import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:spk_app_frontend/common/bloc/interfaces/update.cubit.interface.dart';
import 'package:spk_app_frontend/common/views/views.dart';
import 'package:spk_app_frontend/features/auth/auth.dart';
import 'package:spk_app_frontend/features/regions/models/models.dart';
import 'package:spk_app_frontend/features/users/bloc/user_actions/regions_and_teams.cubit.dart';
import 'package:spk_app_frontend/features/users/bloc/user_actions/user_permissions.cubit.dart';
import 'package:spk_app_frontend/features/users/models/models.dart';
import 'package:spk_app_frontend/features/users/repositories/interfaces.dart';

class AddRoleAction extends StatefulWidget {
  const AddRoleAction({
    super.key,
    required this.userId,
    required this.roleInfo,
    this.regionsAndTeamsCubit,
    this.userPermissionsCubit,
  });

  final String userId;
  final RoleInfo roleInfo;
  final RegionsAndTeamsCubit Function(BuildContext)? regionsAndTeamsCubit;
  final UserPermissionsCubit Function(BuildContext)? userPermissionsCubit;

  @override
  State<AddRoleAction> createState() => _AddRoleActionState();
}

class _AddRoleActionState extends State<AddRoleAction> {
  Role? _selectedRole;
  Region? _selectedRegion;
  Team? _selectedTeam;
  final regionControler = TextEditingController();
  final teamControler = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final currentUser = context.read<AuthCubit>().currentUser;
    final asAdmin = currentUser.checkRole([Role.admin]);
    return BlocProvider(
      create: widget.userPermissionsCubit ??
          (context) => UserPermissionsCubit(
                context.read<IPermissionsRepository>(),
                widget.userId,
              ),
      child: BlocListener<UserPermissionsCubit, UpdateState>(
        listener: (context, state) {
          switch (state) {
            case UpdateSuccess():
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Rola dodana'),
                ),
              );
              context.pop(true);
              break;
            case UpdateFailure():
              late final String message;
              switch (state.code) {
                case 'region-id-required':
                  message = 'Wybierz region';
                  break;
                case 'user-not-found':
                  message = 'Użytkownik nie istnieje';
                  break;
                case 'active-groups':
                  message =
                      'Nie można usunąć użytkownika ze starego zespołu. Posiada on przypisane aktywne króliki.';
                  break;
                case 'region-not-found':
                  message = 'Region nie istnieje';
                  break;
                case 'team-not-found':
                  message = 'Zespół nie istnieje';
                  break;
                case 'user-not-active':
                  message = 'Użytkownik nie jest aktywny';
                  break;
                default:
                  message = 'Nie udało się dodać roli';
              }

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    message,
                    textAlign: TextAlign.center,
                  ),
                ),
              );
              break;
            default:
          }
        },
        child: _InjectRegionsAndTeams(
          regionsAndTeamsCubit: widget.regionsAndTeamsCubit,
          regionsIds: currentUser.checkRole([Role.admin])
              ? null
              : currentUser.managerRegions!.map((e) => e.toString()),
          builder: (context, regions, teams) {
            final managerRegions = regions.where((e) =>
                !widget.roleInfo.managerRegions.contains(e.id.toString()));
            final observerRegions = regions.where((e) =>
                !widget.roleInfo.observerRegions.contains(e.id.toString()));

            return LayoutBuilder(builder: (context, constraints) {
              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: DropdownMenu<Role>(
                      key: const Key('roleDropdown'),
                      label: const Text('Rola'),
                      width: constraints.maxWidth * 0.8,
                      onSelected: (Role? role) {
                        setState(() {
                          _selectedRole = role;
                          _selectedRegion = null;
                          regionControler.clear();
                        });
                      },
                      dropdownMenuEntries: [
                        if (asAdmin && !widget.roleInfo.isAdmin)
                          DropdownMenuEntry(
                            value: Role.admin,
                            label: Role.admin.displayName,
                          ),
                        DropdownMenuEntry(
                          value: Role.volunteer,
                          label: Role.volunteer.displayName,
                        ),
                        if (managerRegions.isNotEmpty)
                          DropdownMenuEntry(
                            value: Role.regionManager,
                            label: Role.regionManager.displayName,
                          ),
                        if (observerRegions.isNotEmpty)
                          DropdownMenuEntry(
                            value: Role.regionRabbitObserver,
                            label: Role.regionRabbitObserver.displayName,
                          ),
                      ],
                    ),
                  ),
                  if (_selectedRole == Role.regionManager ||
                      _selectedRole == Role.regionRabbitObserver)
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: DropdownMenu<Region>(
                        key: const Key('regionDropdown'),
                        label: const Text('Region'),
                        width: constraints.maxWidth * 0.8,
                        controller: regionControler,
                        onSelected: (Region? region) {
                          setState(() {
                            _selectedRegion = region;
                          });
                        },
                        dropdownMenuEntries:
                            (_selectedRole == Role.regionManager
                                    ? managerRegions
                                    : observerRegions)
                                .map(
                                  (region) => DropdownMenuEntry(
                                    value: region,
                                    label: region.name ?? 'id: ${region.id}',
                                  ),
                                )
                                .toList(),
                      ),
                    ),
                  if (_selectedRole == Role.volunteer)
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: DropdownMenu<Team?>(
                        key: const Key('teamDropdown'),
                        label: const Text('Zespół'),
                        width: constraints.maxWidth * 0.8,
                        controller: teamControler,
                        menuHeight: constraints.maxHeight,
                        onSelected: (Team? team) {
                          setState(() {
                            _selectedTeam = team;
                          });
                        },
                        dropdownMenuEntries: [
                          const DropdownMenuEntry(
                              value: null, label: 'Nowy zespół'),
                          ...teams.map(
                            (team) => DropdownMenuEntry(
                              value: team,
                              label: team.name,
                            ),
                          ),
                        ],
                      ),
                    ),
                  FilledButton(
                    onPressed: () {
                      if (_selectedRole == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Wybierz rolę'),
                          ),
                        );
                        return;
                      }
                      if (_selectedRole == Role.regionManager ||
                          _selectedRole == Role.regionRabbitObserver) {
                        if (_selectedRegion == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Wybierz region'),
                            ),
                          );
                          return;
                        }
                      }

                      context.read<UserPermissionsCubit>().addRoleToUser(
                            _selectedRole!,
                            regionId: _selectedRegion?.id,
                            teamId: _selectedTeam?.id,
                          );
                    },
                    child: const Text('Dodaj'),
                  ),
                ],
              );
            });
          },
        ),
      ),
    );
  }
}

class _InjectRegionsAndTeams extends StatelessWidget {
  const _InjectRegionsAndTeams({
    this.regionsIds,
    required this.builder,
    this.regionsAndTeamsCubit,
  });

  final Iterable<String>? regionsIds;
  final Widget Function(BuildContext, Iterable<Region>, Iterable<Team>) builder;
  final RegionsAndTeamsCubit Function(BuildContext)? regionsAndTeamsCubit;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: regionsAndTeamsCubit ??
          (context) => RegionsAndTeamsCubit(
                teamsRepository: context.read<ITeamsRepository>(),
              )..fetch(regionsIds),
      child: BlocBuilder<RegionsAndTeamsCubit, RegionsAndTeamsState>(
        builder: (context, state) {
          switch (state) {
            case RegionsAndTeamsInitial():
              return const InitialView();
            case RegionsAndTeamsFailure():
              return FailureView(
                message: 'Nie udało się pobrać danych',
                onPressed: () =>
                    context.read<RegionsAndTeamsCubit>().fetch(regionsIds),
              );
            case RegionsAndTeamsSuccess():
              return builder(context, state.regions, state.teams);
          }
        },
      ),
    );
  }
}
