import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:spk_app_frontend/common/extensions/date_time.extension.dart';
import 'package:spk_app_frontend/features/rabbit-notes/bloc/rabbit_note_create.cubit.dart';
import 'package:spk_app_frontend/features/rabbit-notes/models/dto.dart';
import 'package:spk_app_frontend/features/rabbit-notes/models/models.dart';
import 'package:spk_app_frontend/features/rabbit-notes/repositories/interfaces.dart';
import 'package:spk_app_frontend/features/rabbit-notes/views/views/rabbit_note_modify.view.dart';

/// A page for creating a new rabbit note.
///
/// RabbitNote will be created based on the provided [rabbitId].
/// If [rabbitName] is provided, it will passed to the next page.
/// If [isVetVisitInitial] is true, the initial type of the visit will be set to VetVisit.
class RabbitNoteCreatePage extends StatefulWidget {
  const RabbitNoteCreatePage({
    super.key,
    required this.rabbitId,
    this.rabbitName,
    this.isVetVisitInitial,
    this.rabbitNoteCreateCubit,
  });

  final int rabbitId;
  final String? rabbitName;
  final bool? isVetVisitInitial;
  final RabbitNoteCreateCubit Function(BuildContext)? rabbitNoteCreateCubit;

  @override
  State<RabbitNoteCreatePage> createState() => _RabbitNoteCreatePageState();
}

class _RabbitNoteCreatePageState extends State<RabbitNoteCreatePage> {
  final _formKey = GlobalKey<FormState>();
  late final _editControlers =
      FieldControlers(isVetVisit: widget.isVetVisitInitial == true);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: widget.rabbitNoteCreateCubit ??
          (context) => RabbitNoteCreateCubit(
                rabbitNotesRepository: context.read<IRabbitNotesRepository>(),
              ),
      child: BlocListener<RabbitNoteCreateCubit, RabbitNoteCreateState>(
        listener: (context, state) {
          switch (state) {
            case RabbitNoteCreated():
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  key: Key('successSnackBar'),
                  content: Text(
                    'Notatka została dodana.',
                  ),
                ),
              );
              context.pushReplacement(
                '/note/${state.rabbitNoteId}',
                extra: {'rabbitName': widget.rabbitName},
              );
            case RabbitNoteCreateFailure():
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  key: Key('errorSnackBar'),
                  content: Text(
                    'Wystąpił błąd podczas dodawania notatki.',
                  ),
                ),
              );

            default:
          }
        },
        child: Builder(builder: (context) {
          return Scaffold(
            appBar: AppBar(
              actions: [
                IconButton(
                  key: const Key('submitButton'),
                  icon: const Icon(Icons.send_rounded),
                  onPressed: () => _onSubmit(context),
                ),
              ],
              title: const Text('Dodaj notatkę'),
            ),
            body: Form(
              key: _formKey,
              child: RabbitNoteModifyView(
                canChangeType: true,
                editControlers: _editControlers,
              ),
            ),
          );
        }),
      ),
    );
  }

  void _onSubmit(BuildContext context) {
    if (_formKey.currentState!.validate()) {
      late final VetVisit? vetVisit;
      if (_editControlers.isVetVisit) {
        if (_editControlers.types.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              key: Key('errorSnackBar'),
              content: Text(
                'Wybierz przynajmniej jeden typ wizyty.',
              ),
            ),
          );
          return;
        }

        vetVisit = VetVisit(
          date: DateTimeExtension.parseFromDate(
              _editControlers.dateControler.text),
          visitInfo: _editControlers.types.map((type) {
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
          }).toList(),
        );
      } else {
        vetVisit = null;
      }

      final rabbitNoteCreateDto = RabbitNoteCreateDto(
        rabbitId: widget.rabbitId,
        description: _editControlers.descriptionControler.text,
        weight: double.tryParse(_editControlers.weightControler.text),
        vetVisit: vetVisit,
      );

      context
          .read<RabbitNoteCreateCubit>()
          .createRabbitNote(rabbitNoteCreateDto);
    }
  }
}
