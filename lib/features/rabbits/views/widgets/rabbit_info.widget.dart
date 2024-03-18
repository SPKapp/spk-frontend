import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:spk_app_frontend/features/rabbits/bloc/rabbit.cubit.dart';

class RabbitInfo extends StatelessWidget {
  const RabbitInfo({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RabbitCubit, RabbitState>(
      builder: (context, state) {
        switch (state) {
          case RabbitInitial():
            return const Center(child: CircularProgressIndicator());
          case RabbitFailure():
            return const Center(child: Text('Failed to fetch rabbit'));
          case RabbitSuccess():
            return Text('Rabbit: ${state.rabbit.name}, id: ${state.rabbit.id}');
        }
      },
    );
  }
}
