import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:spk_app_frontend/features/rabbits/bloc/rabbits.bloc.dart';
import 'package:spk_app_frontend/features/rabbits/repositories/repositories.dart';
import 'package:spk_app_frontend/features/rabbits/views/views/rabbits_list.view.dart';

class MyRabbitsPage extends StatelessWidget {
  const MyRabbitsPage({super.key, this.drawer});

  final Widget? drawer;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => RabbitsBloc(
        rabbitsRepository: context.read<RabbitsRepository>(),
        queryType: RabbitsQueryType.my,
      )..add(const FeatchRabbits()),
      child: BlocBuilder<RabbitsBloc, RabbitsState>(
        builder: (context, state) {
          late Widget body;

          switch (state) {
            case RabbitsInitial():
              body = const Center(child: CircularProgressIndicator());
            case RabbitsFailure():
              body = const Center(child: Text('Failed to fetch rabbits'));
            case RabbitsSuccess():
              body = RabbitsListView(
                rabbitsGroups: state.rabbitsGroups,
                hasReachedMax: state.hasReachedMax,
              );
          }

          return Scaffold(
            appBar: AppBar(
              title: const Text('My Rabbits'),
            ),
            drawer: drawer,
            body: body,
          );
        },
      ),
    );
  }
}
