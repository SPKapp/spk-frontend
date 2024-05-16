import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:spk_app_frontend/common/extensions/extensions.dart';
import 'package:spk_app_frontend/common/views/pages/get_one.page.dart';
import 'package:spk_app_frontend/features/adoption/bloc/rabbit_group.cubit.dart';
import 'package:spk_app_frontend/features/adoption/bloc/update_rabbit_group.cubit.dart';
import 'package:spk_app_frontend/features/adoption/views/views/update_adoption_info.view.dart';
import 'package:spk_app_frontend/features/rabbits/models/dto/rabbit_group_update.dto.dart';
import 'package:spk_app_frontend/features/rabbits/models/models.dart';
import 'package:spk_app_frontend/features/rabbits/repositories/interfaces.dart';

class UpdateAdoptionInfoPage extends StatefulWidget {
  const UpdateAdoptionInfoPage({
    super.key,
    required this.rabbitGroupId,
    this.updateCubit,
    this.rabbitGroupCubit,
  });

  final String rabbitGroupId;
  final UpdateRabbitGroupCubit Function(BuildContext)? updateCubit;
  final RabbitGroupCubit Function(BuildContext)? rabbitGroupCubit;

  @override
  State<UpdateAdoptionInfoPage> createState() => _UpdateAdoptionInfoPageState();
}

class _UpdateAdoptionInfoPageState extends State<UpdateAdoptionInfoPage> {
  late final _editControlers = FieldControlers();

  @override
  void dispose() {
    _editControlers.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: widget.updateCubit ??
              (_) => UpdateRabbitGroupCubit(
                    rabbitgroupId: widget.rabbitGroupId,
                    rabbitGroupsRepository:
                        context.read<IRabbitGroupsRepository>(),
                  ),
        ),
        BlocProvider(
          create: widget.rabbitGroupCubit ??
              (context) => RabbitGroupCubit(
                    rabbitGroupId: widget.rabbitGroupId,
                    rabbitGroupsRepository:
                        context.read<IRabbitGroupsRepository>(),
                  )..fetch(),
        ),
      ],
      child: BlocListener<UpdateRabbitGroupCubit, UpdateRabbitGroupState>(
        listener: (context, state) {
          switch (state) {
            case UpdatedRabbitGroup():
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  key: Key('successSnackBar'),
                  content: Text('Zaktualizowano grupę królików'),
                ),
              );
              context.pop(true);
              break;
            case UpdateRabbitGroupFailure():
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  key: Key('failureSnackBar'),
                  content: Text('Nie udało się zaktualizować grupy królików'),
                ),
              );
              break;
            default:
              break;
          }
        },
        child: GetOnePage<RabbitGroup, RabbitGroupCubit>(
            id: widget.rabbitGroupId,
            defaultTitle: 'Informacje o adopcji',
            errorInfo: 'Nie udało się pobrać grupy królików',
            actionsBuilder: (context, rabbitGroup) => [
                  IconButton(
                    key: const Key('saveButton'),
                    icon: const Icon(Icons.save),
                    onPressed: () => _onSubmit(context, rabbitGroup),
                  ),
                ],
            builder: (context, rabbitGroup) {
              _loadFieldControlers(rabbitGroup);
              return UpdateAdoptionInfoView(
                editControlers: _editControlers,
              );
            }),
      ),
    );
  }

  void _loadFieldControlers(RabbitGroup rabbitGroup) {
    _editControlers.descriptionControler.text =
        rabbitGroup.adoptionDescription ?? '';
    _editControlers.dateControler.text =
        rabbitGroup.adoptionDate?.toDateString() ?? '';
  }

  void _onSubmit(BuildContext context, RabbitGroup rabbitGroup) {
    context.read<UpdateRabbitGroupCubit>().update(
          RabbitGroupUpdateDto(
            id: rabbitGroup.id,
            adoptionDescription: _editControlers.descriptionControler.text,
            adoptionDate: _editControlers.dateControler.text.isNotEmpty
                ? DateTimeExtension.parseFromDate(
                    _editControlers.dateControler.text,
                  )
                : null,
          ),
        );
  }
}
