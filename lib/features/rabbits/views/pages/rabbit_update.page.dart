import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:spk_app_frontend/common/extensions/extensions.dart';
import 'package:spk_app_frontend/common/views/views.dart';
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

  final int rabbitId;
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
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: widget.rabbitCubit ??
              (context) => RabbitCubit(
                    rabbitsRepository: context.read<IRabbitsRepository>(),
                    rabbitId: widget.rabbitId,
                  )..fetchRabbit(),
        ),
        BlocProvider(
          create: widget.rabbitUpdateCubit ??
              (context) => RabbitUpdateCubit(
                    rabbitsRepository: context.read<IRabbitsRepository>(),
                  ),
        ),
      ],
      child: BlocListener<RabbitUpdateCubit, RabbitUpdateState>(
        listener: (context, state) {
          switch (state) {
            case RabbitUpdated():
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Królik został zaktualizowany'),
                ),
              );
              context.pop();
              break;
            case RabbitUpdateFailure():
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Nie udało się zaktualizować królika'),
                ),
              );
            default:
          }
        },
        child: BlocBuilder<RabbitCubit, RabbitState>(
          builder: (context, state) {
            late AppBar appBar;
            late Widget body;

            final currentUser = context.read<AuthCubit>().currentUser;

            switch (state) {
              case RabbitInitial():
                appBar = AppBar();
                body = const InitialView();
              case RabbitFailure():
                appBar = AppBar();
                body = FailureView(
                  message: 'Nie udało się pobrać królika',
                  onPressed: () => context.read<RabbitCubit>().fetchRabbit(),
                );
              case RabbitSuccess():
                _loadFieldControlers(state.rabbit);

                appBar = AppBar(
                  actions: [
                    IconButton(
                      icon: const Icon(Icons.save),
                      onPressed: () => _onSubmit(context, state.rabbit),
                    ),
                  ],
                  title: Text(
                    state.rabbit.name,
                    style: Theme.of(context)
                        .textTheme
                        .displaySmall!
                        .copyWith(fontWeight: FontWeight.w500),
                  ),
                );
                body = Form(
                  key: _formKey,
                  child: RabbitModifyView(
                    editControlers: _editControlers,
                    privileged:
                        currentUser.checkRole([Role.regionManager, Role.admin]),
                  ),
                );
            }
            return Scaffold(
              appBar: appBar,
              body: body,
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
    if (rabbit.status != null) {
      _editControlers.selectedStatus = rabbit.status!;
    }
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
              status: _editControlers.selectedStatus != rabbit.status
                  ? _editControlers.selectedStatus
                  : null,
            ),
          );
    }
  }
}
