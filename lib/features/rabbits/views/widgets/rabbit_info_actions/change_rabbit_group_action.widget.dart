import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:spk_app_frontend/common/bloc/interfaces/get_list.bloc.interface.dart';
import 'package:spk_app_frontend/common/views/views/get_list.view.dart';
import 'package:spk_app_frontend/features/rabbits/bloc/rabbit_update.cubit.dart';
import 'package:spk_app_frontend/features/rabbits/bloc/rabbits_list.bloc.dart';
import 'package:spk_app_frontend/features/rabbits/models/dto.dart';
import 'package:spk_app_frontend/features/rabbits/models/models.dart';
import 'package:spk_app_frontend/features/rabbits/repositories/interfaces.dart';

class ChangeRabbitGroupAction extends StatefulWidget {
  const ChangeRabbitGroupAction({
    super.key,
    required this.rabbit,
    this.rabbitsListBloc,
    this.rabbitUpdateCubit,
  });

  final Rabbit rabbit;
  final RabbitsListBloc Function(BuildContext)? rabbitsListBloc;
  final RabbitUpdateCubit Function(BuildContext)? rabbitUpdateCubit;

  @override
  State<ChangeRabbitGroupAction> createState() =>
      _ChangeRabbitGroupActionState();
}

class _ChangeRabbitGroupActionState extends State<ChangeRabbitGroupAction> {
  late String? _selectedRabbitGroupId = widget.rabbit.rabbitGroup?.id;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: widget.rabbitsListBloc ??
                (context) => RabbitsListBloc(
                      rabbitsRepository: context.read<IRabbitsRepository>(),
                      args: FindRabbitsArgs(
                        limit: 0,
                        regionsIds: [widget.rabbit.rabbitGroup!.region!.id],
                      ),
                    )..add(const FetchList()),
          ),
          BlocProvider(
            create: widget.rabbitUpdateCubit ??
                (context) => RabbitUpdateCubit(
                      rabbitsRepository: context.read<IRabbitsRepository>(),
                    ),
          ),
        ],
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Text(
                'Wybierz nową grupę zaprzyjaźnionych królików',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            Expanded(
              child: BlocListener<RabbitUpdateCubit, RabbitUpdateState>(
                listener: (context, state) {
                  switch (state) {
                    case RabbitUpdated():
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Zapisano zmiany'),
                        ),
                      );
                      context.pop(true);
                    case RabbitUpdateFailure():
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Nie udało się zmienić grupy królika'),
                        ),
                      );
                    default:
                  }
                },
                child:
                    GetListView<RabbitGroup, FindRabbitsArgs, RabbitsListBloc>(
                  errorInfo: 'Nie udało się pobrać listy grup królików',
                  builder: (context, rabbitGroups) {
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        DropdownButton<String>(
                          items: [
                            const DropdownMenuItem(
                              value: '0',
                              child: Text('Nowa grupa'),
                            ),
                            ...rabbitGroups.map(
                              (rabbitGroup) => DropdownMenuItem(
                                value: rabbitGroup.id,
                                child: Text(rabbitGroup.name),
                              ),
                            )
                          ],
                          onChanged: (value) {
                            setState(() {
                              _selectedRabbitGroupId = value;
                            });
                          },
                          value: _selectedRabbitGroupId,
                        ),
                        const SizedBox(height: 20),
                        FilledButton(
                          onPressed: () async {
                            _selectedRabbitGroupId ??= '0';
                            if (_selectedRabbitGroupId !=
                                widget.rabbit.rabbitGroup!.id) {
                              final result = await showDialog<bool>(
                                  context: context,
                                  barrierDismissible: false,
                                  builder: (context) => AlertDialog(
                                        title: const Text(
                                            'Czy na pewno chcesz zmienić grupę królika?'),
                                        content: const Text(
                                          'Spowoduje to usunięcie królika z obecnej grupy, a jeśli grupa stanie się pusta, zostanie usunięta wraz z wszystkimi informacjami o niej. Czy na pewno chcesz kontynuować?',
                                          textAlign: TextAlign.justify,
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.of(context)
                                                    .pop(false),
                                            child: const Text('Anuluj'),
                                          ),
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.of(context).pop(true),
                                            child: const Text('Zmień'),
                                          ),
                                        ],
                                      ));
                              if (result == true && context.mounted) {
                                context
                                    .read<RabbitUpdateCubit>()
                                    .changeRabbitGroup(
                                      widget.rabbit.id,
                                      _selectedRabbitGroupId!,
                                    );
                              } else if (context.mounted) {
                                context.pop();
                              }
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Nie zmieniono grupy królika'),
                                ),
                              );
                              context.pop();
                            }
                          },
                          child: const Text('Zapisz'),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
