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
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Rabbit Info'),
        ),
        body: const RabbitInfo(),
      ),
    );
  }
}
