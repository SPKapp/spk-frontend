import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:spk_app_frontend/common/views/views.dart';
import 'package:spk_app_frontend/features/adoption/bloc/rabbit_group.cubit.dart';
import 'package:spk_app_frontend/features/adoption/views/views/adoption_info.view.dart';
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
      child: BlocBuilder<RabbitGroupCubit, RabbitGroupState>(
        builder: (context, state) {
          late final Widget body;

          switch (state) {
            case RabbitGroupInitial():
              body = const InitialView();
            case RabbitGroupFailure():
              body = FailureView(
                message: 'Nie udało się pobrać grupy królików',
                onPressed: () => context.read<RabbitGroupCubit>().fetch(),
              );
            case RabbitGroupSuccess():
              body = AdoptionInfoView(rabbitGroup: state.rabbitGroup);
          }

          return Scaffold(
            appBar: AppBar(
              title: const Text('Informacje o adopcji'),
              actions: [
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
              ],
            ),
            body: body,
          );
        },
      ),
    );
  }
}
