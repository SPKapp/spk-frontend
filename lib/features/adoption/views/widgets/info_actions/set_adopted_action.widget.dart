import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'package:spk_app_frontend/common/bloc/interfaces/update.cubit.interface.dart';
import 'package:spk_app_frontend/common/extensions/extensions.dart';
import 'package:spk_app_frontend/common/views/widgets/form_fields.dart';
import 'package:spk_app_frontend/features/adoption/bloc/update_rabbit_group.cubit.dart';
import 'package:spk_app_frontend/features/rabbits/models/dto/rabbit_group_update.dto.dart';
import 'package:spk_app_frontend/features/rabbits/models/models.dart';
import 'package:spk_app_frontend/features/rabbits/repositories/interfaces.dart';

class SetAdoptedAction extends StatefulWidget {
  const SetAdoptedAction({
    super.key,
    required this.rabbitGroupId,
    this.rabbitGroupUpdateCubit,
  });

  final String rabbitGroupId;
  final UpdateRabbitGroupCubit Function(BuildContext)? rabbitGroupUpdateCubit;

  @override
  State<SetAdoptedAction> createState() => _SetAdoptedActionState();
}

class _SetAdoptedActionState extends State<SetAdoptedAction> {
  DateTime date = DateUtils.dateOnly(DateTime.now());
  late final controller = TextEditingController(text: date.toDateString());

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: widget.rabbitGroupUpdateCubit ??
          (context) => UpdateRabbitGroupCubit(
                rabbitgroupId: widget.rabbitGroupId,
                rabbitGroupsRepository: context.read<IRabbitGroupsRepository>(),
              ),
      child: BlocListener<UpdateRabbitGroupCubit, UpdateState>(
        listener: (context, state) {
          switch (state) {
            case UpdateSuccess():
              Navigator.of(context).pop(true);
            case UpdateFailure():
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Nie udało się zmienić statusu królików'),
                ),
              );

              Navigator.of(context).pop(false);
            default:
          }
        },
        child: Builder(builder: (context) {
          return Column(
            children: [
              const Text(
                'Spowoduje to zmianę statusu wszystkich królików w grupie na "Adoptowane".',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              DateField(
                controller: controller,
                labelText: 'Data adopcji',
                hintText: 'Podaj datę adopcji',
                icon: FontAwesomeIcons.calendarDay,
                onTap: (DateTime date) async {
                  setState(() {
                    controller.text = date.toDateString();
                    this.date = date;
                  });
                },
              ),
              FilledButton(
                onPressed: () async {
                  if (date.isAfter(DateTime.now().add(
                    const Duration(days: 1),
                  ))) {
                    final result = await showDialog<bool>(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: const Text(
                              'Data adopcji jest w przyszłości',
                              textAlign: TextAlign.center,
                            ),
                            content: const Text(
                              '''Czy na pewno chcesz ustawić datę adopcji w przyszłości?, nie spowoduje to zmiany statusu królików, ale data zostanie zapisana.
Status królików zostanie zmieniony na "Adoptowane" dopiero po upływie daty adopcji. Jeśli w międzyczasie zostanie wywołana akcja zmiany statusu królików, data adopcji zostanie usunięta.''',
                              textAlign: TextAlign.center,
                            ),
                            actions: [
                              TextButton(
                                onPressed: () =>
                                    Navigator.of(context).pop(false),
                                child: const Text('Anuluj'),
                              ),
                              TextButton(
                                onPressed: () =>
                                    Navigator.of(context).pop(true),
                                child: const Text('Zapisz'),
                              ),
                            ],
                          );
                        });

                    if (result != true) return;
                  }
                  if (context.mounted) {
                    context.read<UpdateRabbitGroupCubit>().update(
                          RabbitGroupUpdateDto(
                            id: widget.rabbitGroupId,
                            adoptionDate: date,
                            status: RabbitGroupStatus.adopted,
                          ),
                        );
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
