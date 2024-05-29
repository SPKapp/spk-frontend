import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:spk_app_frontend/common/bloc/interfaces/update.cubit.interface.dart';

import 'package:spk_app_frontend/features/rabbits/bloc/rabbit_update.cubit.dart';
import 'package:spk_app_frontend/features/rabbits/models/models.dart';
import 'package:spk_app_frontend/features/rabbits/repositories/interfaces.dart';
import 'package:spk_app_frontend/features/rabbits/views/widgets/form_fields.dart';

/// A widget that represents an action to change a volunteer of a rabbit.
class ChangeStatus extends StatefulWidget {
  const ChangeStatus({
    super.key,
    required this.rabbit,
    this.rabbitUpdateCubit,
  });

  final Rabbit rabbit;
  final RabbitUpdateCubit Function(BuildContext)? rabbitUpdateCubit;

  @override
  State<ChangeStatus> createState() => _ChangeStatusState();
}

class _ChangeStatusState extends State<ChangeStatus> {
  late RabbitStatus? _selectedStatus = widget.rabbit.status;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: widget.rabbitUpdateCubit ??
          (context) => RabbitUpdateCubit(
                rabbitsRepository: context.read<IRabbitsRepository>(),
              ),
      child: BlocListener<RabbitUpdateCubit, UpdateState>(
        listener: (context, state) {
          switch (state) {
            case UpdateSuccess():
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Zapisano zmiany'),
                ),
              );
              context.pop(true);
            case UpdateFailure():
              late final String text;

              switch (state.code) {
                case 'not-all-deceased':
                  text =
                      'Aby zmienić status królika na "${RabbitStatus.deceased.displayName}" wszystkie króliki z grupy muszą mieć ten status. Użyj opcji zmień grupę i dodaj nową grupę dla zmarłego królika.';
                  break;
                case 'not-all-adopted':
                  text =
                      'Aby zmienić status królika na "${RabbitStatus.adopted.displayName}" wszystkie króliki z grupy muszą mieć ten status. Użyj menu adopcji aby zmienić status dla wszystkich królików w grupie.';
                  break;
                case 'unavailable-group-status':
                  text =
                      'Nie można ustalić statusu grupy królików. Prawdopodobnie żadne króliki nie mają statusu "${RabbitStatus.inTreatment.displayName}".';
                  break;
                default:
                  text = 'Nie udało się zmienić statusu królika.';
              }

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  duration: const Duration(seconds: 5),
                  content: Text(text, textAlign: TextAlign.center),
                ),
              );
            default:
          }
        },
        child: Builder(builder: (context) {
          return Column(
            children: [
              RabbitStatusDropdown(
                onSelected: (status) {
                  setState(() {
                    _selectedStatus = status;
                  });
                },
                initialSelection: _selectedStatus ?? RabbitStatus.unknown,
              ),
              if (_selectedStatus == RabbitStatus.inTreatment)
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                      'Jeśli data przyjęcia nie została ustawiona, zostanie ustawiona na dziś.\nJeśli chcesz ją zmienić, przejdź do edycji królika.',
                      textAlign: TextAlign.center),
                ),
              const SizedBox(height: 15),
              FilledButton(
                onPressed: () {
                  if (_selectedStatus == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Nie wybrano statusu'),
                      ),
                    );
                    context.pop();
                  } else if (_selectedStatus != widget.rabbit.status) {
                    context.read<RabbitUpdateCubit>().changeRabbitStatus(
                          widget.rabbit.id,
                          _selectedStatus!,
                        );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Nie zmieniono statusu'),
                      ),
                    );
                    context.pop();
                  }
                },
                child: const Text('Zapisz'),
              ),
            ],
          );
        }),
      ),
    );
  }
}
