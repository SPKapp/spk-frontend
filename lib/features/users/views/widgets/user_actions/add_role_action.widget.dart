import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

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
      child: BlocListener<UserPermissionsCubit, UserPermissionsState>(
        listener: (context, state) {
          switch (state) {
            case UserPermissionsSuccess():
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Rola dodana'),
                ),
              );
              context.pop(true);
              break;
            case UserPermissionsFailure():
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Nie udało się dodać roli'),
                ),
              );
              break;
            default:
          }
        },
        child: FractionallySizedBox(
          widthFactor: 1.0,
          heightFactor: 0.6,
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
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          'Dodaj rolę',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      ),
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
                          _selectedRole == Role.regionRabbitObserver ||
                          _selectedRole == Role.volunteer)
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
                            dropdownMenuEntries: (_selectedRole ==
                                        Role.regionManager
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
                            requestFocusOnTap: true,
                            enableFilter: true,
                            enableSearch: true,
                            onSelected: (Team? team) {
                              setState(() {
                                _selectedTeam = null;
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
                                regionId: _selectedRegion?.id.toString(),
                                teamId: _selectedTeam?.id.toString(),
                              );
                        },
                        child: const Text('Dodaj'),
                      ),
                    ],
                  ),
                );
              });
            },
          ),
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
