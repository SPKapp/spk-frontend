import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:spk_app_frontend/features/rabbit-notes/bloc/rabbit_note_update.cubit.dart';
import 'package:spk_app_frontend/features/rabbit-notes/repositories/interfaces.dart';

class RabbitNoteRemoveAction extends StatelessWidget {
  const RabbitNoteRemoveAction({
    super.key,
    required this.rabbitNoteId,
    this.rabbitNoteUpdateCubit,
  });

  final String rabbitNoteId;
  final RabbitNoteUpdateCubit Function(BuildContext)? rabbitNoteUpdateCubit;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: rabbitNoteUpdateCubit ??
          (context) => RabbitNoteUpdateCubit(
                rabbitNoteId: rabbitNoteId,
                rabbitNotesRepository: context.read<IRabbitNotesRepository>(),
              ),
      child: BlocListener<RabbitNoteUpdateCubit, RabbitNoteUpdateState>(
        listener: (context, state) {
          switch (state) {
            case RabbitNoteUpdated():
              Navigator.of(context).pop(true);
            case RabbitNoteUpdateFailure():
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Nie udało się usunąć notatki'),
                ),
              );

              Navigator.of(context).pop(false);
            default:
          }
        },
        child: Builder(builder: (context) {
          return AlertDialog(
            title: const Text('Usuwanie notatki'),
            content: const Text('Czy na pewno chcesz usunąć notatkę?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Anuluj'),
              ),
              TextButton(
                onPressed: () =>
                    context.read<RabbitNoteUpdateCubit>().removeRabbitNote(),
                child: const Text('Usuń'),
              ),
            ],
          );
        }),
      ),
    );
  }
}
