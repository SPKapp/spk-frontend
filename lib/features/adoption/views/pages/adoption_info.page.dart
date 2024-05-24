import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:spk_app_frontend/common/views/pages/get_one.page.dart';
import 'package:spk_app_frontend/common/views/widgets/actions/show_my_modal_bottom_sheet.function.dart';
import 'package:spk_app_frontend/features/adoption/bloc/rabbit_group.cubit.dart';
import 'package:spk_app_frontend/features/adoption/views/views/adoption_info.view.dart';
import 'package:spk_app_frontend/features/adoption/views/widgets/info_actions.dart';
import 'package:spk_app_frontend/features/rabbits/models/models.dart';
import 'package:spk_app_frontend/features/rabbits/repositories/interfaces.dart';

class AdoptionInfoPage extends StatelessWidget {
  const AdoptionInfoPage({
    super.key,
    required this.rabbitGroupId,
    this.rabbitGroupCubit,
  });

  final String rabbitGroupId;
  final RabbitGroupCubit Function(BuildContext)? rabbitGroupCubit;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: rabbitGroupCubit ??
          (context) => RabbitGroupCubit(
                rabbitGroupId: rabbitGroupId,
                rabbitGroupsRepository: context.read<IRabbitGroupsRepository>(),
              )..fetch(),
      child: GetOnePage<RabbitGroup, RabbitGroupCubit>(
        defaultTitle: 'Informacje o adopcji',
        errorInfo: 'Nie udało się pobrać grupy królików',
        actionsBuilder: (context, rabbitGroup) {
          final allAdoptable =
              rabbitGroup.status == RabbitGroupStatus.adoptable;
          final allAdopted = rabbitGroup.status == RabbitGroupStatus.adopted;
          return [
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () async {
                final result =
                    await context.push('/rabbitGroup/$rabbitGroupId/edit');
                if (result == true && context.mounted) {
                  context.read<RabbitGroupCubit>().fetch();
                }
              },
            ),
            if (allAdopted || allAdoptable)
              PopupMenuButton(
                key: const Key('rabbit_group_info_menu'),
                itemBuilder: (context) => [
                  if (allAdoptable)
                    PopupMenuItem(
                      child: const Text('Oznacz jako adoptowane'),
                      onTap: () async {
                        await showModalMyBottomSheet<bool>(
                            context: context,
                            title: 'Oznacz króliki jako adoptowane',
                            builder: (_) => SetAdoptedAction(
                                  rabbitGroupId: rabbitGroupId,
                                ),
                            onClosing: (result) {
                              if (result == true) {
                                context.read<RabbitGroupCubit>().fetch();
                              }
                            });
                      },
                    ),
                  if (allAdopted)
                    PopupMenuItem(
                      child: const Text('Cofnij adopcję'),
                      onTap: () async {
                        final result = await showDialog<bool>(
                            context: context,
                            builder: (context) {
                              return UnsetAdoptedAction(
                                rabbitGroupId: rabbitGroupId,
                              );
                            });

                        if (context.mounted && result == true) {
                          context.read<RabbitGroupCubit>().fetch();
                        }
                      },
                    ),
                ],
              ),
          ];
        },
        builder: (context, rabbitGroup) =>
            AdoptionInfoView(rabbitGroup: rabbitGroup),
      ),
    );
  }
}
