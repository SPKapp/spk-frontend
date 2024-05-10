import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'package:spk_app_frontend/common/views/widgets/lists/card.widget.dart';
import 'package:spk_app_frontend/features/auth/auth.dart';
import 'package:spk_app_frontend/features/regions/bloc/regions_list.bloc.dart';
import 'package:spk_app_frontend/features/regions/models/dto.dart';
import 'package:spk_app_frontend/features/regions/repositories/interfaces.dart';
import 'package:spk_app_frontend/features/users/models/models.dart';

// TODO: Implement This
class RolesCard extends StatelessWidget {
  RolesCard({
    super.key,
    List<RoleEntity>? roles,
  })  : _hasAnyRole = roles?.isNotEmpty ?? false,
        _isAdmin = roles?.any((role) => role.role == Role.admin),
        _isVolunteer = roles?.any((role) => role.role == Role.volunteer),
        _managerRegions = roles
            ?.where((role) => role.role == Role.regionManager)
            .map((role) => role.additionalInfo!)
            .toList(),
        _observerRegions = roles
            ?.where((role) => role.role == Role.regionRabbitObserver)
            .map((role) => role.additionalInfo!)
            .toList();

  final bool _hasAnyRole;
  final bool? _isAdmin;
  final bool? _isVolunteer;
  final List<String>? _managerRegions;
  final List<String>? _observerRegions;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {
        Set<String>? regionsIds;

        if (_managerRegions?.isNotEmpty == true ||
            _observerRegions?.isNotEmpty == true) {
          regionsIds = <String>{
            ...?_managerRegions,
            ...?_observerRegions,
          };
        }
        return RegionsListBloc(
          regionsRepository: context.read<IRegionsRepository>(),
          args: FindRegionsArgs(
            limit: 0,
            regionsIds: regionsIds,
          ),
        )..add(const FetchRegions());
      },
      child: AppCard(
        child: _hasAnyRole
            ? BlocBuilder<RegionsListBloc, RegionsListState>(
                builder: (context, state) {
                  late final Widget managerRegions;
                  late final Widget observerRegions;

                  switch (state) {
                    case RegionsListInitial():
                      managerRegions =
                          const Center(child: CircularProgressIndicator());
                      observerRegions = managerRegions;
                      break;
                    case RegionsListSuccess():
                      managerRegions = Text(state.regions
                          .where(
                              (e) => _managerRegions!.contains(e.id.toString()))
                          .map((e) => e.name)
                          .join('\n'));
                      observerRegions = Text(state.regions
                          .where((e) =>
                              _observerRegions!.contains(e.id.toString()))
                          .map((e) => e.name)
                          .join('\n'));
                      break;
                    case RegionsListFailure():
                      managerRegions = const Row(
                        children: [
                          Icon(FontAwesomeIcons.ghost),
                          Text('Błąd pobierania danych'),
                        ],
                      );
                      observerRegions = managerRegions;
                      break;
                  }

                  return Column(
                    children: [
                      if (_isAdmin == true)
                        const ListTile(
                          title: Text('Administrator'),
                          subtitle: Text('Pełna kontrola nad aplikacją'),
                          leading: Icon(FontAwesomeIcons.userShield),
                        ),
                      if (_isAdmin == true &&
                          (_isVolunteer == true ||
                              _managerRegions?.isNotEmpty == true ||
                              _observerRegions?.isNotEmpty == true))
                        const Divider(),
                      if (_isVolunteer == true)
                        const ListTile(
                          title: Text('Wolontariusz'),
                          subtitle: Text('Dom Tymczasowy dla Królików'),
                          leading: Icon(FontAwesomeIcons.houseUser),
                        ),
                      if (_isVolunteer == true &&
                          (_managerRegions?.isNotEmpty == true ||
                              _observerRegions?.isNotEmpty == true))
                        const Divider(),
                      if (_managerRegions?.isNotEmpty == true)
                        ListTile(
                          title: const Text('Menedżer regionu'),
                          subtitle: managerRegions,
                          leading: const Icon(FontAwesomeIcons.userGear),
                        ),
                      if (_managerRegions?.isNotEmpty == true &&
                          _observerRegions?.isNotEmpty == true)
                        const Divider(),
                      if (_observerRegions?.isNotEmpty == true)
                        ListTile(
                          title: const Text('Obserwator regionu'),
                          subtitle: observerRegions,
                          leading: const Icon(FontAwesomeIcons.userNinja),
                        ),
                    ],
                  );
                },
              )
            : const Text('Brak ról'),
      ),
    );
  }
}
