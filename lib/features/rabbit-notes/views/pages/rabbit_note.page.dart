import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:spk_app_frontend/common/views/views.dart';
import 'package:spk_app_frontend/features/auth/auth.dart';
import 'package:spk_app_frontend/features/rabbit-notes/bloc/rabbit_note.cubit.dart';
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

  final int id;
  final String? rabbitName;
  final RabbitNoteCubit Function(BuildContext)? rabbitNoteCubit;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: rabbitNoteCubit ??
          (context) => RabbitNoteCubit(
                rabbitNoteId: id,
                rabbitNotesRepository: context.read<IRabbitNotesRepository>(),
              )..fetchRabbitNote(),
      child: BlocBuilder<RabbitNoteCubit, RabbitNoteState>(
        builder: (context, state) {
          final user = context.read<AuthCubit>().currentUser;
          bool editable = false;
          final isAtLeastRegionManager =
              user.checkRole([Role.regionManager, Role.admin]);

          late final Widget body;

          switch (state) {
            case RabbitNoteInitial():
              body = const InitialView();
            case RabbitNoteFailure():
              body = FailureView(
                message: 'Nie udało się pobrać notatki',
                onPressed: () =>
                    context.read<RabbitNoteCubit>().fetchRabbitNote(),
              );
            case RabbitNoteSuccess():
              editable = isAtLeastRegionManager ||
                  (state.rabbitNote.createdBy != null &&
                      user.checkId(state.rabbitNote.createdBy));
              body = RabbitNoteView(rabbitNote: state.rabbitNote);
          }

          return Scaffold(
            appBar: AppBar(
              title: Text(rabbitName ?? 'Notatka'),
              actions: editable
                  ? [
                      IconButton(
                        key: const Key('rabbitNoteEditButton'),
                        icon: const Icon(Icons.edit),
                        onPressed: () async {
                          final result = await context.push<bool>(
                            '/note/$id/edit',
                          );
                          if (context.mounted && result == true) {
                            context.read<RabbitNoteCubit>().fetchRabbitNote();
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
                              context.read<RabbitNoteCubit>().fetchRabbitNote();
                            }
                          }
                        },
                      ),
                    ]
                  : null,
            ),
            body: body,
          );
        },
      ),
    );
  }
}
