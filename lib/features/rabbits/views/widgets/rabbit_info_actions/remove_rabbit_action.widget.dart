import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spk_app_frontend/common/bloc/interfaces/update.cubit.interface.dart';

import 'package:spk_app_frontend/features/rabbits/bloc/rabbit_update.cubit.dart';
import 'package:spk_app_frontend/features/rabbits/repositories/interfaces.dart';

class RemoveRabbitAction extends StatelessWidget {
  const RemoveRabbitAction({
    super.key,
    required this.rabbitId,
    this.rabbitUpdateCubit,
  });

  final String rabbitId;
  final RabbitUpdateCubit Function(BuildContext)? rabbitUpdateCubit;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: rabbitUpdateCubit ??
          (context) => RabbitUpdateCubit(
                rabbitsRepository: context.read<IRabbitsRepository>(),
              ),
      child: BlocListener<RabbitUpdateCubit, UpdateState>(
        listener: (context, state) {
          switch (state) {
            case UpdateSuccess():
              Navigator.of(context).pop(true);
            case UpdateFailure():
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Nie udało się usunąć królika'),
                ),
              );

              Navigator.of(context).pop(false);
            default:
          }
        },
        child: Builder(builder: (context) {
          return AlertDialog(
            title: const Text(
              'Czy na pewno chcesz usunąć królika?',
              textAlign: TextAlign.center,
            ),
            content: const Text(
              'Spowoduje to usunięcie królika z bazy danych, wraz z powiązanymi notatkami, zdjęciami i innymi danymi.',
              textAlign: TextAlign.justify,
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Anuluj'),
              ),
              TextButton(
                onPressed: () =>
                    context.read<RabbitUpdateCubit>().removeRabbit(rabbitId),
                child: const Text('Usuń'),
              ),
            ],
          );
        }),
      ),
    );
  }
}
