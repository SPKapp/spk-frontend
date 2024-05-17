import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:spk_app_frontend/features/auth/auth.dart';
import 'package:spk_app_frontend/features/rabbits/views/widgets/form_fields.dart';
import 'package:spk_app_frontend/features/regions/bloc/regions_list.bloc.dart';
import 'package:spk_app_frontend/features/regions/models/models.dart';
import 'package:spk_app_frontend/features/users/bloc/user_actions/user_permissions.cubit.dart';
import 'package:spk_app_frontend/features/users/models/models.dart';
import 'package:spk_app_frontend/features/users/repositories/interfaces.dart';

class RemoveRoleAction extends StatefulWidget {
  const RemoveRoleAction({
    super.key,
    required this.userId,
    required this.roleInfo,
    this.regionsListBloc,
    this.userPermissionsCubit,
  });

  final String userId;
  final RoleInfo roleInfo;
  final RegionsListBloc Function(BuildContext)? regionsListBloc;
  final UserPermissionsCubit Function(BuildContext)? userPermissionsCubit;

  @override
  State<RemoveRoleAction> createState() => _RemoveRoleActionState();
}

class _RemoveRoleActionState extends State<RemoveRoleAction> {
  Role? _selectedRole;
  Region? _selectedRegion;
  final controler = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final currentUser = context.read<AuthCubit>().currentUser;
    final asAdmin = currentUser.checkRole([Role.admin]);

    return FractionallySizedBox(
      widthFactor: 1.0,
      heightFactor: 0.6,
      child: widget.roleInfo.hasAnyRole
          ? BlocProvider(
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
                          content: Text('Rola usunięta'),
                        ),
                      );
                      context.pop(true);
                      break;
                    case UserPermissionsFailure():
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Nie udało się usunąć roli'),
                        ),
                      );
                      break;
                    default:
                  }
                },
                child: InjectRegionsList(
                  regionsListBloc: widget.regionsListBloc,
                  regionsIds: {
                    ...widget.roleInfo.managerRegions,
                    ...widget.roleInfo.observerRegions,
                  },
                  builder: (context, regions) {
                    final managerRegions = regions.where((e) => widget
                        .roleInfo.managerRegions
                        .contains(e.id.toString()));
                    final observerRegions = regions.where((e) => widget
                        .roleInfo.observerRegions
                        .contains(e.id.toString()));

                    return LayoutBuilder(builder: (context, constraints) {
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                'Usuń rolę',
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
                                    controler.clear();
                                  });
                                },
                                dropdownMenuEntries: [
                                  if (asAdmin &&
                                      widget.roleInfo.isAdmin &&
                                      !currentUser
                                          .checkId(int.parse(widget.userId)))
                                    DropdownMenuEntry(
                                      value: Role.admin,
                                      label: Role.admin.displayName,
                                    ),
                                  if (widget.roleInfo.isVolunteer)
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
                                      label:
                                          Role.regionRabbitObserver.displayName,
                                    ),
                                ],
                              ),
                            ),
                            if (_selectedRole == Role.regionManager ||
                                _selectedRole == Role.regionRabbitObserver)
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: DropdownMenu<Region?>(
                                  key: const Key('regionDropdown'),
                                  label: const Text('Region'),
                                  width: constraints.maxWidth * 0.8,
                                  controller: controler,
                                  onSelected: (Region? region) {
                                    setState(() {
                                      _selectedRegion = region;
                                    });
                                  },
                                  dropdownMenuEntries: [
                                    if (asAdmin)
                                      const DropdownMenuEntry(
                                        value: null,
                                        label: 'Wszystkie regiony',
                                      ),
                                    ...(_selectedRole == Role.regionManager
                                            ? managerRegions
                                            : observerRegions)
                                        .map(
                                      (region) => DropdownMenuEntry(
                                        value: region,
                                        label:
                                            region.name ?? 'id: ${region.id}',
                                      ),
                                    )
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
                                    _selectedRole ==
                                        Role.regionRabbitObserver) {
                                  if (!asAdmin && _selectedRegion == null) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Wybierz region'),
                                      ),
                                    );
                                    return;
                                  }
                                }

                                context
                                    .read<UserPermissionsCubit>()
                                    .removeRoleFromUser(
                                      _selectedRole!,
                                      regionId: _selectedRegion?.id.toString(),
                                    );
                              },
                              child: const Text('Usuń'),
                            ),
                          ],
                        ),
                      );
                    });
                  },
                ),
              ),
            )
          : const Center(child: Text('Brak ról do usunięcia')),
    );
  }
}
