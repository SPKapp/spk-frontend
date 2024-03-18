import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:spk_app_frontend/features/rabbits/bloc/rabbit.cubit.dart';
import 'package:spk_app_frontend/features/rabbits/repositories/repositories.dart';
import 'package:spk_app_frontend/features/rabbits/views/widgets/rabbit_info.widget.dart';

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
          rabbitsRepository: context.read<RabbitsRepository>(),
          rabbitId: rabbitId)
        ..fetchRabbit(),
      child: BlocBuilder<RabbitCubit, RabbitState>(
        builder: (context, state) {
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
                title: Text(
                  state.rabbit.name,
                  style: Theme.of(context)
                      .textTheme
                      .displaySmall!
                      .copyWith(fontWeight: FontWeight.w500),
                ),
              );
              body = RabbitInfo(rabbit: state.rabbit);
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
