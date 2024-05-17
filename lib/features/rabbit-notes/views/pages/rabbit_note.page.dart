import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:spk_app_frontend/common/views/pages/get_one.page.dart';
import 'package:spk_app_frontend/features/auth/auth.dart';
import 'package:spk_app_frontend/features/rabbit-notes/bloc/rabbit_note.cubit.dart';
import 'package:spk_app_frontend/features/rabbit-notes/models/models.dart';
import 'package:spk_app_frontend/features/rabbit-notes/repositories/interfaces.dart';
import 'package:spk_app_frontend/features/rabbit-notes/views/views/rabbit_note.view.dart';
import 'package:spk_app_frontend/features/rabbit-notes/views/widgets/item_page.dart';

/// A page widget for displaying a rabbit note.
///
/// The page displays a rabbit note with the given [id].
/// If [rabbitName] is provided, it will be displayed in the app bar.
///
/// This widget assumes that the [IRabbitNotesRepository] is provided above by [RepositoryProvider].
class RabbitNotePage extends StatelessWidget {
  const RabbitNotePage({
    super.key,
    required this.id,
    this.rabbitName,
    this.rabbitNoteCubit,
  });

  final String id;
  final String? rabbitName;
  final RabbitNoteCubit Function(BuildContext)? rabbitNoteCubit;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: rabbitNoteCubit ??
          (context) => RabbitNoteCubit(
                rabbitNoteId: id,
                rabbitNotesRepository: context.read<IRabbitNotesRepository>(),
              )..fetch(),
      child: GetOnePage<RabbitNote, RabbitNoteCubit>(
        defaultTitle: rabbitName ?? 'Notatka',
        errorInfo: 'Nie udało się pobrać notatki',
        actionsBuilder: (context, rabbitNote) {
          final user = context.read<AuthCubit>().currentUser;

          if (user.checkRole([Role.regionManager, Role.admin]) ||
              (rabbitNote.createdBy != null &&
                  user.checkId(int.tryParse(rabbitNote.createdBy ?? '')))) {
            return [
              IconButton(
                key: const Key('rabbitNoteEditButton'),
                icon: const Icon(Icons.edit),
                onPressed: () async {
                  final result = await context.push<bool>(
                    '/note/$id/edit',
                  );
                  if (context.mounted && result == true) {
                    context.read<RabbitNoteCubit>().fetch();
                  }
                },
              ),
              IconButton(
                key: const Key('rabbitNoteDeleteButton'),
                icon: const Icon(Icons.delete),
                onPressed: () async {
                  final result = await showDialog<bool>(
                      context: context,
                      builder: (context) {
                        return RabbitNoteRemoveAction(
                          rabbitNoteId: id,
                        );
                      });

                  if (context.mounted && result == true) {
                    if (context.canPop()) {
                      context.pop({
                        'deleted': true,
                      });
                    } else {
                      context.read<RabbitNoteCubit>().fetch();
                    }
                  }
                },
              ),
            ];
          }
          return null;
        },
        builder: (context, rabbitNote) =>
            RabbitNoteView(rabbitNote: rabbitNote),
      ),
    );
  }
}
