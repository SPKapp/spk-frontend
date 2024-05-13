import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:spk_app_frontend/common/views/views.dart';
import 'package:spk_app_frontend/features/auth/auth.dart';

import 'package:spk_app_frontend/features/rabbits/bloc/rabbit.cubit.dart';
import 'package:spk_app_frontend/features/rabbits/repositories/interfaces.dart';
import 'package:spk_app_frontend/features/rabbits/views/views/rabbit_info.view.dart';
import 'package:spk_app_frontend/features/rabbits/views/widgets/rabbit_info_actions.dart';

/// A page that displays information about a rabbit.
///
/// This widget assumes that the [IRabbitsRepository] is provided above by [RepositoryProvider].
class RabbitInfoPage extends StatelessWidget {
  const RabbitInfoPage({
    super.key,
    required this.rabbitId,
    this.rabbitCubit,
  });

  final int rabbitId;
  final RabbitCubit Function(BuildContext)? rabbitCubit;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: rabbitCubit ??
          (context) => RabbitCubit(
                rabbitsRepository: context.read<IRabbitsRepository>(),
                rabbitId: rabbitId,
              )..fetchRabbit(),
      child: BlocBuilder<RabbitCubit, RabbitState>(
        builder: (context, state) {
          final user = context.read<AuthCubit>().currentUser;
          final isAtLeastRegionManager =
              user.checkRole([Role.regionManager, Role.admin]);

          late AppBar appBar;
          late Widget body;

          switch (state) {
            case RabbitInitial():
              appBar = AppBar();
              body = const InitialView();
            case RabbitFailure():
              appBar = AppBar();
              body = FailureView(
                message: 'Nie udało się pobrać królika',
                onPressed: () => context.read<RabbitCubit>().fetchRabbit(),
              );
            case RabbitSuccess():
              final editable = isAtLeastRegionManager ||
                  (user.checkRole([Role.volunteer]) &&
                      user.checkTeamId(int.tryParse(
                          state.rabbit.rabbitGroup?.team?.id ?? '')));

              appBar = AppBar(
                actions: editable
                    ? [
                        IconButton(
                          key: const Key('rabbit_info_edit_button'),
                          icon: const Icon(Icons.edit),
                          onPressed: () async {
                            await context.push('/rabbit/$rabbitId/edit');
                            if (context.mounted) {
                              context.read<RabbitCubit>().fetchRabbit();
                            }
                          },
                        ),
                        if (isAtLeastRegionManager)
                          PopupMenuButton(
                            key: const Key('rabbit_info_popup_menu'),
                            itemBuilder: (_) => [
                              PopupMenuItem(
                                child: const Text('Zmień DT'),
                                onTap: () async {
                                  final result =
                                      await showModalBottomSheet<bool>(
                                          context: context,
                                          builder: (_) {
                                            return ChangeVolunteerAction(
                                              rabbit: state.rabbit,
                                            );
                                          });
                                  if (result != null &&
                                      result &&
                                      context.mounted) {
                                    context.read<RabbitCubit>().fetchRabbit();
                                  }
                                },
                              ),
                              PopupMenuItem(
                                child: const Text('Zmień zaprzyjaźnioną grupę'),
                                onTap: () async {
                                  final result =
                                      await showModalBottomSheet<bool>(
                                          context: context,
                                          builder: (_) {
                                            return ChangeRabbitGroupAction(
                                              rabbit: state.rabbit,
                                            );
                                          });
                                  if (result != null &&
                                      result &&
                                      context.mounted) {
                                    context.read<RabbitCubit>().fetchRabbit();
                                  }
                                },
                              ),
                              PopupMenuItem(
                                  child: const Text('Usuń Królika'),
                                  onTap: () async {
                                    final result = await showDialog<bool>(
                                        context: context,
                                        builder: (_) {
                                          return RemoveRabbitAction(
                                            rabbitId: state.rabbit.id,
                                          );
                                        });
                                    if (context.mounted && result == true) {
                                      if (context.canPop()) {
                                        context.pop({
                                          'deleted': true,
                                        });
                                      } else {
                                        context
                                            .read<RabbitCubit>()
                                            .fetchRabbit();
                                      }
                                    }
                                  })
                            ],
                          ),
                      ]
                    : null,
                title: Text(
                  state.rabbit.name,
                  style: Theme.of(context)
                      .textTheme
                      .displaySmall!
                      .copyWith(fontWeight: FontWeight.w500),
                ),
              );
              body = RabbitInfoView(
                rabbit: state.rabbit,
                admin: isAtLeastRegionManager,
              );
          }
          return Scaffold(
            appBar: appBar,
            body: body,
          );
        },
      ),
    );
  }
}
