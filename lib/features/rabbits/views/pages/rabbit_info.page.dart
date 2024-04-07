import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:spk_app_frontend/app/bloc/app.bloc.dart';

import 'package:spk_app_frontend/features/rabbits/bloc/rabbit.cubit.dart';
import 'package:spk_app_frontend/features/rabbits/repositories/interfaces.dart';
import 'package:spk_app_frontend/features/rabbits/views/views/rabbit_info.view.dart';
import 'package:spk_app_frontend/features/rabbits/views/widgets/rabbit_info_actions.dart';

class RabbitInfoPage extends StatelessWidget {
  const RabbitInfoPage({
    super.key,
    required this.rabbitId,
  });

  final int rabbitId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => RabbitCubit(
        rabbitsRepository: context.read<IRabbitsRepository>(),
        rabbitId: rabbitId,
      )..fetchRabbit(),
      child: BlocBuilder<RabbitCubit, RabbitState>(
        builder: (context, state) {
          final user = context.read<AppBloc>().state.currentUser;
          final isRegionManager = user.isRegionManager;

          late AppBar appBar;
          late Widget body;

          switch (state) {
            case RabbitInitial():
              appBar = AppBar();
              body = const Center(child: CircularProgressIndicator());
            case RabbitFailure():
              appBar = AppBar();
              body = const Center(child: Text('Failed to fetch rabbit'));
            case RabbitSuccess():
              appBar = AppBar(
                actions: [
                  IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () async {
                      await context.push('/rabbit/$rabbitId/edit');
                      if (context.mounted) {
                        context.read<RabbitCubit>().fetchRabbit();
                      }
                    },
                  ),
                  PopupMenuButton(
                    itemBuilder: (_) => [
                      if (isRegionManager) ...[
                        PopupMenuItem(
                          child: const Text('Zmień DT'),
                          onTap: () async {
                            final result = await showModalBottomSheet<bool>(
                                context: context,
                                builder: (_) {
                                  return ChangeVolunteerAction(
                                    rabbit: state.rabbit,
                                  );
                                });
                            if (result != null && result && context.mounted) {
                              context.read<RabbitCubit>().fetchRabbit();
                            }
                          },
                        ),
                        PopupMenuItem(
                          child: const Text('Zmień zaprzyjaźnioną grupę'),
                          onTap: () async {
                            final result = await showModalBottomSheet<bool>(
                                context: context,
                                builder: (_) {
                                  return ChangeRabbitGroupAction(
                                    rabbit: state.rabbit,
                                  );
                                });
                            if (result != null && result && context.mounted) {
                              context.read<RabbitCubit>().fetchRabbit();
                            }
                          },
                        ),
                      ],
                    ],
                  ),
                ],
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
                admin: isRegionManager,
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
