import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:spk_app_frontend/common/views/widgets/actions.dart';
import 'package:spk_app_frontend/common/views/widgets/lists/card.widget.dart';
import 'package:spk_app_frontend/features/rabbits/bloc/rabbits_search.bloc.dart';
import 'package:spk_app_frontend/features/rabbits/models/dto.dart';
import 'package:spk_app_frontend/features/rabbits/models/models.dart';
import 'package:spk_app_frontend/features/rabbits/repositories/interfaces.dart';

class RabbitsSearchAction extends StatelessWidget {
  const RabbitsSearchAction({
    super.key,
    required this.args,
    this.rabbitsSearchBloc,
  });

  final FindRabbitsArgs Function() args;
  final RabbitsSearchBloc Function(BuildContext)? rabbitsSearchBloc;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: rabbitsSearchBloc ??
          (context) => RabbitsSearchBloc(
                rabbitsRepository: context.read<IRabbitsRepository>(),
                args: args(),
              ),
      child: SearchAction<RabbitGroup, RabbitsSearchBloc>(
          errorInfo: 'Wystąpił błąd podczas wyszukiwania królików.',
          itemBuilder: (context, rabbitGroup) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: rabbitGroup.rabbits.map((rabbit) {
                return AppCard(
                  child: TextButton(
                    onPressed: () => context.push('/rabbit/${rabbit.id}'),
                    child: Text(
                      rabbit.name,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                );
              }).toList(),
            );
          }),
    );
  }
}
