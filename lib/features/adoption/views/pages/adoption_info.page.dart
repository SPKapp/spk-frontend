import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:spk_app_frontend/common/bloc/interfaces/get_one.cubit.interface.dart';

import 'package:spk_app_frontend/common/views/pages/get_one.page.dart';
import 'package:spk_app_frontend/common/views/widgets/actions/show_my_modal_bottom_sheet.function.dart';
import 'package:spk_app_frontend/features/adoption/bloc/rabbit_group.cubit.dart';
import 'package:spk_app_frontend/features/adoption/views/views/adoption_info.view.dart';
import 'package:spk_app_frontend/features/adoption/views/widgets/info_actions.dart';
import 'package:spk_app_frontend/features/rabbits/models/models.dart';
import 'package:spk_app_frontend/features/rabbits/repositories/interfaces.dart';

class AdoptionInfoPage extends StatefulWidget {
  const AdoptionInfoPage({
    super.key,
    required this.rabbitGroupId,
    this.launchSetAdoptedAction = false,
    this.rabbitGroupCubit,
  });

  final String rabbitGroupId;
  final bool launchSetAdoptedAction;
  final RabbitGroupCubit Function(BuildContext)? rabbitGroupCubit;

  @override
  State<AdoptionInfoPage> createState() => _AdoptionInfoPageState();
}

class _AdoptionInfoPageState extends State<AdoptionInfoPage> {
  late bool launchSetAdoptedAction = widget.launchSetAdoptedAction;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: widget.rabbitGroupCubit ??
          (context) => RabbitGroupCubit(
                rabbitGroupId: widget.rabbitGroupId,
                rabbitGroupsRepository: context.read<IRabbitGroupsRepository>(),
              )..fetch(),
      child: BlocListener<RabbitGroupCubit, GetOneState>(
        listener: (context, state) {
          if (state is GetOneSuccess<RabbitGroup> && launchSetAdoptedAction) {
            launchSetAdoptedAction = false;
            final adoptable = state.data.status == RabbitGroupStatus.adoptable;
            final adopted = state.data.status == RabbitGroupStatus.adopted;

            if (adopted || adoptable) {
              _onAdoptedClicked(context, state.data);
            }
          }
        },
        child: GetOnePage<RabbitGroup, RabbitGroupCubit>(
          defaultTitle: 'Informacje o adopcji',
          errorInfo: 'Nie udało się pobrać grupy królików',
          actionsBuilder: (context, rabbitGroup) {
            final adoptable = rabbitGroup.status == RabbitGroupStatus.adoptable;
            final adopted = rabbitGroup.status == RabbitGroupStatus.adopted;

            return [
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () async {
                  final result = await context
                      .push('/rabbitGroup/${widget.rabbitGroupId}/edit');
                  if (result == true && context.mounted) {
                    context.read<RabbitGroupCubit>().fetch();
                  }
                },
              ),
              if (adopted || adoptable)
                PopupMenuButton(
                  key: const Key('rabbit_group_info_menu'),
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      child: Text(adopted
                          ? 'Zmień datę adopcji'
                          : 'Oznacz jako adoptowane'),
                      onTap: () => _onAdoptedClicked(context, rabbitGroup),
                    ),
                    if (adopted || rabbitGroup.adoptionDate != null)
                      PopupMenuItem(
                        child: const Text('Cofnij adopcję'),
                        onTap: () async {
                          final result = await showDialog<bool>(
                              context: context,
                              builder: (context) {
                                return UnsetAdoptedAction(
                                  rabbitGroupId: widget.rabbitGroupId,
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
      ),
    );
  }

  void _onAdoptedClicked(BuildContext context, RabbitGroup rabbitGroup) async {
    await showModalMyBottomSheet<bool>(
        context: context,
        title: 'Oznacz króliki jako adoptowane',
        builder: (_) => SetAdoptedAction(
              rabbitGroupId: widget.rabbitGroupId,
              date: rabbitGroup.adoptionDate,
            ),
        onClosing: (result) {
          if (result == true) {
            context.read<RabbitGroupCubit>().fetch();
          }
        });
  }
}
