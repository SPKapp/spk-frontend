import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:spk_app_frontend/features/rabbits/bloc/rabbits_list.bloc.dart';
import 'package:spk_app_frontend/features/rabbits/repositories/interfaces.dart';
import 'package:spk_app_frontend/features/rabbits/views/views/rabbits_list.view.dart';

class MyRabbitsPage extends StatelessWidget {
  const MyRabbitsPage({super.key, this.drawer});

  final Widget? drawer;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => RabbitsListBloc(
        rabbitsRepository: context.read<IRabbitsRepository>(),
        queryType: RabbitsQueryType.my,
      )..add(const FetchRabbits()),
      child: BlocBuilder<RabbitsListBloc, RabbitsListState>(
        builder: (context, state) {
          late Widget body;

          switch (state) {
            case RabbitsListInitial():
              body = const Center(child: CircularProgressIndicator());
            case RabbitsListFailure():
              body = const Center(child: Text('Failed to fetch rabbits'));
            case RabbitsListSuccess():
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
