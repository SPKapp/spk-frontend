import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:spk_app_frontend/features/rabbits/bloc/rabbits.bloc.dart';
import 'package:spk_app_frontend/features/rabbits/repositories/repositories.dart';
import 'package:spk_app_frontend/features/rabbits/views/volunteer/rabbits_list.view.dart';

class RabbitsListPage extends StatelessWidget {
  const RabbitsListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          RabbitsBloc(context.read<RabbitsRepository>())..add(RabbitsFeached()),
      child: const RabbitsListView(),
    );
  }
}
