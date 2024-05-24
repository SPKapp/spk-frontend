import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spk_app_frontend/common/bloc/interfaces/update.cubit.interface.dart';
import 'package:spk_app_frontend/features/adoption/bloc/update_rabbit_group.cubit.dart';
import 'package:spk_app_frontend/features/rabbits/models/dto.dart';
import 'package:spk_app_frontend/features/rabbits/models/models.dart';
import 'package:spk_app_frontend/features/rabbits/repositories/interfaces.dart';

class UnsetAdoptedAction extends StatelessWidget {
  const UnsetAdoptedAction({
    super.key,
    required this.rabbitGroupId,
    this.rabbitGroupUpdateCubit,
  });

  final String rabbitGroupId;
  final UpdateRabbitGroupCubit Function(BuildContext)? rabbitGroupUpdateCubit;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: rabbitGroupUpdateCubit ??
          (context) => UpdateRabbitGroupCubit(
                rabbitgroupId: rabbitGroupId,
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
          return AlertDialog(
            title: const Text('Czy na pewno chcesz cofnąć adopcję?',
                textAlign: TextAlign.center),
            content: const Text(
              'Po cofnięciu adopcji króliki będą ponownie dostępne do adopcji. Data adopcji zostanie usunięta.',
              textAlign: TextAlign.center,
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Anuluj'),
              ),
              TextButton(
                onPressed: () {
                  context.read<UpdateRabbitGroupCubit>().update(
                        RabbitGroupUpdateDto(
                          id: rabbitGroupId,
                          status: RabbitGroupStatus.adoptable,
                        ),
                      );
                },
                child: const Text('Cofnij adopcję'),
              ),
            ],
          );
        }),
      ),
    );
  }
}
