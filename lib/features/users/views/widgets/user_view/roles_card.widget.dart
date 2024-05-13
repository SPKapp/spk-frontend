import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'package:spk_app_frontend/common/views/widgets/lists/card.widget.dart';
import 'package:spk_app_frontend/features/regions/bloc/regions_list.bloc.dart';
import 'package:spk_app_frontend/features/regions/models/dto.dart';
import 'package:spk_app_frontend/features/regions/repositories/interfaces.dart';
import 'package:spk_app_frontend/features/users/models/models.dart';

class RolesCard extends StatelessWidget {
  const RolesCard({
    super.key,
    required this.roleInfo,
    this.regionsListBloc,
  });

  final RoleInfo roleInfo;
  final RegionsListBloc Function(BuildContext)? regionsListBloc;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: regionsListBloc ??
          (context) {
            Set<String>? regionsIds;

            if (roleInfo.managerRegions.isNotEmpty == true ||
                roleInfo.observerRegions.isNotEmpty == true) {
              regionsIds = <String>{
                ...roleInfo.managerRegions,
                ...roleInfo.observerRegions,
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
        child: roleInfo.hasAnyRole
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
                          .where((e) =>
                              roleInfo.managerRegions.contains(e.id.toString()))
                          .map((e) => e.name)
                          .join('\n'));
                      observerRegions = Text(state.regions
                          .where((e) => roleInfo.observerRegions
                              .contains(e.id.toString()))
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
                      if (roleInfo.isAdmin == true)
                        const ListTile(
                          title: Text('Administrator'),
                          subtitle: Text('Pełna kontrola nad aplikacją'),
                          leading: Icon(FontAwesomeIcons.userShield),
                        ),
                      if (roleInfo.isAdmin == true &&
                          (roleInfo.isVolunteer == true ||
                              roleInfo.managerRegions.isNotEmpty == true ||
                              roleInfo.observerRegions.isNotEmpty == true))
                        const Divider(),
                      if (roleInfo.isVolunteer == true)
                        const ListTile(
                          title: Text('Wolontariusz'),
                          subtitle: Text('Dom Tymczasowy dla Królików'),
                          leading: Icon(FontAwesomeIcons.houseUser),
                        ),
                      if (roleInfo.isVolunteer == true &&
                          (roleInfo.managerRegions.isNotEmpty == true ||
                              roleInfo.observerRegions.isNotEmpty == true))
                        const Divider(),
                      if (roleInfo.managerRegions.isNotEmpty == true)
                        ListTile(
                          title: const Text('Menedżer regionu'),
                          subtitle: managerRegions,
                          leading: const Icon(FontAwesomeIcons.userGear),
                        ),
                      if (roleInfo.managerRegions.isNotEmpty == true &&
                          roleInfo.observerRegions.isNotEmpty == true)
                        const Divider(),
                      if (roleInfo.observerRegions.isNotEmpty == true)
                        ListTile(
                          title: const Text('Obserwator regionu'),
                          subtitle: observerRegions,
                          leading: const Icon(FontAwesomeIcons.userNinja),
                        ),
                    ],
                  );
                },
              )
            : const ListTile(
                title: Text('Brak przyznanych uprawnień'),
                leading: Icon(FontAwesomeIcons.squareMinus),
              ),
      ),
    );
  }
}
