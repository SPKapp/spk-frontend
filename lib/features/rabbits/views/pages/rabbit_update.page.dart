import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:spk_app_frontend/common/bloc/interfaces/update.cubit.interface.dart';

import 'package:spk_app_frontend/common/extensions/extensions.dart';
import 'package:spk_app_frontend/common/views/pages/get_one.page.dart';
import 'package:spk_app_frontend/features/auth/auth.dart';

import 'package:spk_app_frontend/features/rabbits/bloc/rabbit.cubit.dart';
import 'package:spk_app_frontend/features/rabbits/bloc/rabbit_update.cubit.dart';
import 'package:spk_app_frontend/features/rabbits/models/dto.dart';
import 'package:spk_app_frontend/features/rabbits/models/models.dart';
import 'package:spk_app_frontend/features/rabbits/repositories/interfaces.dart';
import 'package:spk_app_frontend/features/rabbits/views/views/rabbit_modify.view.dart';

/// A page for updating a rabbit's information.
class RabbitUpdatePage extends StatefulWidget {
  const RabbitUpdatePage({
    super.key,
    required this.rabbitId,
    this.rabbitCubit,
    this.rabbitUpdateCubit,
  });

  final String rabbitId;
  final RabbitCubit Function(BuildContext)? rabbitCubit;
  final RabbitUpdateCubit Function(BuildContext)? rabbitUpdateCubit;

  @override
  State<RabbitUpdatePage> createState() => _RabbitUpdatePageState();
}

class _RabbitUpdatePageState extends State<RabbitUpdatePage> {
  final _formKey = GlobalKey<FormState>();
  final FieldControlers _editControlers = FieldControlers();

  @override
  void dispose() {
    _editControlers.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = context.read<AuthCubit>().currentUser;

    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: widget.rabbitCubit ??
              (context) => RabbitCubit(
                    rabbitsRepository: context.read<IRabbitsRepository>(),
                    rabbitId: widget.rabbitId,
                  )..fetch(),
        ),
        BlocProvider(
          create: widget.rabbitUpdateCubit ??
              (context) => RabbitUpdateCubit(
                    rabbitsRepository: context.read<IRabbitsRepository>(),
                  ),
        ),
      ],
      child: BlocListener<RabbitUpdateCubit, UpdateState>(
        listener: (context, state) {
          switch (state) {
            case UpdateSuccess():
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Królik został zaktualizowany'),
                ),
              );
              context.pop(true);
              break;
            case UpdateFailure():
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Nie udało się zaktualizować królika'),
                ),
              );
            default:
          }
        },
        child: GetOnePage<Rabbit, RabbitCubit>(
          refreshable: false,
          defaultTitle: 'Królik',
          titleBuilder: (context, rabbit) => rabbit.name,
          errorInfo: 'Nie udało się pobrać królika',
          actionsBuilder: (context, rabbit) {
            return [
              IconButton(
                icon: const Icon(Icons.save),
                onPressed: () => _onSubmit(context, rabbit),
              ),
            ];
          },
          builder: (context, rabbit) {
            _loadFieldControlers(rabbit);
            return Form(
              key: _formKey,
              child: RabbitModifyView(
                editControlers: _editControlers,
                privileged:
                    currentUser.checkRole([Role.regionManager, Role.admin]),
              ),
            );
          },
        ),
      ),
    );
  }

  void _loadFieldControlers(Rabbit rabbit) {
    _editControlers.nameControler.text = rabbit.name;
    _editControlers.birthDateControler.text =
        rabbit.birthDate?.toDateString() ?? '';
    _editControlers.colorControler.text = rabbit.color ?? '';
    _editControlers.breedControler.text = rabbit.breed ?? '';
    _editControlers.admissionDateControler.text =
        rabbit.admissionDate?.toDateString() ?? '';
    _editControlers.filingDateControler.text =
        rabbit.fillingDate?.toDateString() ?? '';
    _editControlers.selectedGender = rabbit.gender;
    _editControlers.selectedAdmissionType = rabbit.admissionType;
    _editControlers.confirmedBirthDate = rabbit.confirmedBirthDate;
  }

  void _onSubmit(BuildContext context, Rabbit rabbit) {
    if (_formKey.currentState!.validate()) {
      final birthDate = _editControlers.birthDateControler.text.isNotEmpty
          ? DateTimeExtension.parseFromDate(
              _editControlers.birthDateControler.text)
          : null;
      final admissionDate =
          _editControlers.admissionDateControler.text.isNotEmpty
              ? DateTimeExtension.parseFromDate(
                  _editControlers.admissionDateControler.text)
              : null;
      final fillingDate = _editControlers.filingDateControler.text.isNotEmpty
          ? DateTimeExtension.parseFromDate(
              _editControlers.filingDateControler.text)
          : null;

      context.read<RabbitUpdateCubit>().updateRabbit(
            RabbitUpdateDto(
              id: widget.rabbitId,
              name: (_editControlers.nameControler.text != rabbit.name)
                  ? _editControlers.nameControler.text
                  : null,
              color: (_editControlers.colorControler.text.isNotEmpty &&
                      _editControlers.colorControler.text != rabbit.color)
                  ? _editControlers.colorControler.text
                  : null,
              breed: (_editControlers.breedControler.text.isNotEmpty &&
                      _editControlers.breedControler.text != rabbit.breed)
                  ? _editControlers.breedControler.text
                  : null,
              gender: (_editControlers.selectedGender != rabbit.gender)
                  ? _editControlers.selectedGender
                  : null,
              birthDate: birthDate != rabbit.birthDate ? birthDate : null,
              confirmedBirthDate: _editControlers.confirmedBirthDate !=
                      rabbit.confirmedBirthDate
                  ? _editControlers.confirmedBirthDate
                  : null,
              admissionDate:
                  admissionDate != rabbit.admissionDate ? admissionDate : null,
              admissionType:
                  _editControlers.selectedAdmissionType != rabbit.admissionType
                      ? _editControlers.selectedAdmissionType
                      : null,
              fillingDate:
                  fillingDate != rabbit.fillingDate ? fillingDate : null,
            ),
          );
    }
  }
}
