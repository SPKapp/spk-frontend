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
  late bool _launchSetAdoptedAction = widget.launchSetAdoptedAction;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: widget.rabbitGroupCubit ??
          (context) => RabbitGroupCubit(
                rabbitGroupId: widget.rabbitGroupId,
                rabbitGroupsRepository: context.read<IRabbitGroupsRepository>(),
              )..fetch(),
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
        builder: (context, rabbitGroup) => _OnLoad(
            onLoad: (context) {
              if (_launchSetAdoptedAction) {
                _launchSetAdoptedAction = false;
                _onAdoptedClicked(context, rabbitGroup);
              }
            },
            child: AdoptionInfoView(rabbitGroup: rabbitGroup)),
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

class _OnLoad extends StatefulWidget {
  const _OnLoad({
    required this.child,
    required this.onLoad,
  });

  final Widget child;
  final void Function(BuildContext) onLoad;

  @override
  State<_OnLoad> createState() => __OnLoadState();
}

class __OnLoadState extends State<_OnLoad> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.onLoad(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
