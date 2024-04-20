import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:spk_app_frontend/common/extensions/date_time.extension.dart';
import 'package:spk_app_frontend/common/views/views.dart';
import 'package:spk_app_frontend/common/views/widgets/lists/card.widget.dart';
import 'package:spk_app_frontend/features/rabbit-notes/bloc/rabbit_note.cubit.dart';
import 'package:spk_app_frontend/features/rabbit-notes/models/models.dart';

/// A view for displaying a single Rabbit Note.
class RabbitNoteView extends StatelessWidget {
  const RabbitNoteView({
    super.key,
    required this.rabbitNote,
  });

  final RabbitNote rabbitNote;

  @override
  Widget build(BuildContext context) {
    final isVetVisit = rabbitNote.vetVisit != null;

    return ItemView(
      onRefresh: () async {
        // skip initial state
        Future cubit = context.read<RabbitNoteCubit>().stream.skip(1).first;
        context.read<RabbitNoteCubit>().refreshRabbitNote();
        return cubit;
      },
      child: Column(
        children: [
          AppCard(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    isVetVisit ? 'Wizyta weterynaryjna' : 'Notatka',
                    style: Theme.of(context).textTheme.headlineLarge,
                    textAlign: TextAlign.center,
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        isVetVisit ? 'Data Wizyty:' : 'Data Utworzenia:',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                    Text(
                      (isVetVisit
                              ? rabbitNote.vetVisit?.date?.toDateString()
                              : rabbitNote.createdAt?.toDateTimeString()) ??
                          'Nieznana',
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (rabbitNote.description != null)
            AppCard(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Opis:',
                      style: Theme.of(context).textTheme.titleLarge,
                      textAlign: TextAlign.center,
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        rabbitNote.description!,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          if (rabbitNote.weight != null)
            AppCard(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Waga:',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${rabbitNote.weight} kg',
                    ),
                  ],
                ),
              ),
            ),
          if (isVetVisit)
            AppCard(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    Text(
                      'Typ Wizyty:',
                      style: Theme.of(context).textTheme.titleLarge,
                      textAlign: TextAlign.center,
                    ),
                    ...ListTile.divideTiles(
                      context: context,
                      tiles: (rabbitNote.vetVisit!.visitInfo..sort()).map(
                        (info) => ListTile(
                          leading: Icon(info.visitType.icon),
                          title: Text(info.visitType.displayName),
                          subtitle: info.additionalInfo != null
                              ? Text(info.additionalInfo!,
                                  textAlign: TextAlign.justify)
                              : null,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
