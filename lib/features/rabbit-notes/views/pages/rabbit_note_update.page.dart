import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:spk_app_frontend/common/extensions/extensions.dart';
import 'package:spk_app_frontend/common/views/views.dart';
import 'package:spk_app_frontend/features/rabbit-notes/bloc/rabbit_note.cubit.dart';
import 'package:spk_app_frontend/features/rabbit-notes/bloc/rabbit_note_update.cubit.dart';
import 'package:spk_app_frontend/features/rabbit-notes/models/dto.dart';
import 'package:spk_app_frontend/features/rabbit-notes/models/models.dart';
import 'package:spk_app_frontend/features/rabbit-notes/repositories/interfaces.dart';
import 'package:spk_app_frontend/features/rabbit-notes/views/views/rabbit_note_modify.view.dart';

/// Page for updating rabbit note with given [rabbitNoteId].
class RabbitNoteUpdatePage extends StatefulWidget {
  const RabbitNoteUpdatePage({
    super.key,
    required this.rabbitNoteId,
    this.rabbitNoteCubit,
    this.rabbitNoteUpdateCubit,
  });

  final int rabbitNoteId;
  final RabbitNoteCubit Function(BuildContext)? rabbitNoteCubit;
  final RabbitNoteUpdateCubit Function(BuildContext)? rabbitNoteUpdateCubit;

  @override
  State<RabbitNoteUpdatePage> createState() => _RabbitNoteUpdatePageState();
}

class _RabbitNoteUpdatePageState extends State<RabbitNoteUpdatePage> {
  final _formKey = GlobalKey<FormState>();
  late final _editControlers = FieldControlers();

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: widget.rabbitNoteCubit ??
              (context) => RabbitNoteCubit(
                    rabbitNoteId: widget.rabbitNoteId,
                    rabbitNotesRepository:
                        context.read<IRabbitNotesRepository>(),
                  )..fetchRabbitNote(),
        ),
        BlocProvider(
          create: widget.rabbitNoteUpdateCubit ??
              (context) => RabbitNoteUpdateCubit(
                    rabbitNoteId: widget.rabbitNoteId,
                    rabbitNotesRepository:
                        context.read<IRabbitNotesRepository>(),
                  ),
        ),
      ],
      child: BlocListener<RabbitNoteUpdateCubit, RabbitNoteUpdateState>(
        listener: (context, state) {
          switch (state) {
            case RabbitNoteUpdated():
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  key: Key('successSnackBar'),
                  content: Text('Notatka została zaktualizowana'),
                ),
              );
              context.pop(true);
            case RabbitNoteUpdateFailure():
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  key: Key('errorSnackBar'),
                  content: Text('Nie udało się zaktualizować notatki'),
                ),
              );
            default:
          }
        },
        child: BlocBuilder<RabbitNoteCubit, RabbitNoteState>(
          builder: (context, state) {
            late final Widget body;
            late final List<Widget>? actions;

            switch (state) {
              case RabbitNoteInitial():
                actions = null;
                body = const InitialView();
              case RabbitNoteFailure():
                actions = null;
                body = FailureView(
                  message: 'Nie udało się pobrać notatki',
                  onPressed: () =>
                      context.read<RabbitNoteCubit>().fetchRabbitNote(),
                );
              case RabbitNoteSuccess():
                _loadFieldControlers(state.rabbitNote);
                actions = [
                  IconButton(
                    key: const Key('saveButton'),
                    icon: const Icon(Icons.save),
                    onPressed: () => _onSubmit(context, state.rabbitNote),
                  ),
                ];
                body = Form(
                  key: _formKey,
                  child: RabbitNoteModifyView(
                    editControlers: _editControlers,
                    canChangeType: false,
                  ),
                );
            }

            return Scaffold(
              appBar: AppBar(
                title: const Text('Edytuj notatkę'),
                actions: actions,
              ),
              body: body,
            );
          },
        ),
      ),
    );
  }

  void _loadFieldControlers(RabbitNote rabbitNote) {
    _editControlers.isVetVisit = rabbitNote.vetVisit != null;
    _editControlers.descriptionControler.text = rabbitNote.description ?? '';
    _editControlers.weightControler.text = rabbitNote.weight?.toString() ?? '';

    if (_editControlers.isVetVisit) {
      _editControlers.dateControler.text =
          rabbitNote.vetVisit!.date?.toDateString() ?? '';

      for (var info in rabbitNote.vetVisit!.visitInfo) {
        _editControlers.types.add(info.visitType);

        switch (info.visitType) {
          case VisitType.vaccination:
            _editControlers.vaccinationControler.text =
                info.additionalInfo ?? '';
          case VisitType.operation:
            _editControlers.operationControler.text = info.additionalInfo ?? '';
          case VisitType.chip:
            _editControlers.chipControler.text = info.additionalInfo ?? '';
          default:
        }
      }
    }
  }

  void _onSubmit(BuildContext context, RabbitNote rabbitNote) {
    if (_formKey.currentState!.validate()) {
      VetVisit? vetVisit;

      if (_editControlers.isVetVisit) {
        final date = DateTimeExtension.parseFromDate(
          _editControlers.dateControler.text,
        );
        final visitInfo = _editControlers.types.map((type) {
          String? additionalInfo;

          switch (type) {
            case VisitType.vaccination:
              additionalInfo = _editControlers.vaccinationControler.text;
            case VisitType.operation:
              additionalInfo = _editControlers.operationControler.text;
            case VisitType.chip:
              additionalInfo = _editControlers.chipControler.text;
            default:
          }

          return VisitInfo(
            visitType: type,
            additionalInfo: additionalInfo,
          );
        }).toList();

        vetVisit = VetVisit(
          date: rabbitNote.vetVisit!.date != date ? date : null,
          // Empty list means that there are no changes in visitInfo
          visitInfo: !listEquals(rabbitNote.vetVisit!.visitInfo, visitInfo)
              ? visitInfo
              : [],
        );
      }

      final description = _editControlers.descriptionControler.text;
      final weight =
          double.tryParse(_editControlers.weightControler.text) ?? 0.0;

      final rabbitNoteUpdateDto = RabbitNoteUpdateDto(
        id: rabbitNote.id,
        description: rabbitNote.description != description ? description : null,
        weight: rabbitNote.weight != weight ? weight : null,
        vetVisit: vetVisit,
      );

      context
          .read<RabbitNoteUpdateCubit>()
          .updateRabbitNote(rabbitNoteUpdateDto);
    }
  }
}
