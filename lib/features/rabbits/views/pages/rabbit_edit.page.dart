import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:spk_app_frontend/common/extensions/extensions.dart';

import 'package:spk_app_frontend/features/rabbits/bloc/rabbit.cubit.dart';
import 'package:spk_app_frontend/features/rabbits/models/dto/dto.dart';
import 'package:spk_app_frontend/features/rabbits/repositories/repositories.dart';
import 'package:spk_app_frontend/features/rabbits/views/views/rabbit_modify.view.dart';

class RabbitEditPage extends StatefulWidget {
  const RabbitEditPage({
    super.key,
    required this.rabbitId,
  });

  final int rabbitId;

  @override
  State<RabbitEditPage> createState() => _RabbitEditPageState();
}

class _RabbitEditPageState extends State<RabbitEditPage> {
  final _formKey = GlobalKey<FormState>();
  final FieldControlers _editControlers = FieldControlers();

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => RabbitCubit(
        rabbitsRepository: context.read<RabbitsRepository>(),
        rabbitId: widget.rabbitId,
      )..fetchRabbit(),
      child: BlocConsumer<RabbitCubit, RabbitState>(
        listenWhen: (previous, current) {
          return current is RabbitUpdateFailure || current is RabbitUpdated;
        },
        buildWhen: (previous, current) {
          return current is! RabbitUpdateFailure && current is! RabbitUpdated;
        },
        listener: (context, state) {
          switch (state) {
            case RabbitUpdated():
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Królik został zaktualizowany'),
                ),
              );
              context.pop('/rabbit/${state.rabbit.id}');
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
        builder: (context, state) {
          late AppBar appBar;
          late Widget body;

          switch (state) {
            case RabbitInitial():
              appBar = AppBar();
              body = const Center(child: CircularProgressIndicator());
            case RabbitFailure():
              appBar = AppBar();
              body = const Center(child: Text('Failed to fetch rabbit'));
            case RabbitSuccess():
              _editControlers.nameControler.text = state.rabbit.name;
              _editControlers.birthDateControler.text =
                  state.rabbit.birthDate?.toDateString() ?? '';
              _editControlers.colorControler.text = state.rabbit.color ?? '';
              _editControlers.breedControler.text = state.rabbit.breed ?? '';
              // _editControlers.admissionDateControler.text =
              // state.rabbit.admissionDate?.toDateString() ?? '';
              // _editControlers.filingDateControler.text =
              // state.rabbit.fillingDate?.toDateString() ?? '';
              _editControlers.selectedGender = state.rabbit.gender;
              // _editControlers.selectedAdmissionType = state.rabbit.admissionType;
              _editControlers.confirmedBirthDate =
                  state.rabbit.confirmedBirthDate;

              appBar = AppBar(
                actions: [
                  IconButton(
                    icon: const Icon(Icons.save),
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        context.read<RabbitCubit>().updateRabbit(
                              RabbitUpdateDto(
                                id: state.rabbit.id,
                                name: _editControlers.nameControler.text,
                                color: _editControlers
                                        .colorControler.text.isNotEmpty
                                    ? _editControlers.colorControler.text
                                    : null,
                                breed: _editControlers
                                        .breedControler.text.isNotEmpty
                                    ? _editControlers.breedControler.text
                                    : null,
                                gender: _editControlers.selectedGender,
                                birthDate: (_editControlers
                                        .birthDateControler.text.isNotEmpty)
                                    ? DateTime.parse(
                                        _editControlers.birthDateControler.text)
                                    : null,
                                confirmedBirthDate:
                                    _editControlers.confirmedBirthDate,
                                admissionDate: (_editControlers
                                        .admissionDateControler.text.isNotEmpty)
                                    ? DateTime.parse(_editControlers
                                        .admissionDateControler.text)
                                    : null,
                                admissionType:
                                    _editControlers.selectedAdmissionType,
                                fillingDate: (_editControlers
                                        .filingDateControler.text.isNotEmpty)
                                    ? DateTime.parse(_editControlers
                                        .filingDateControler.text)
                                    : null,
                                // status: Status.unknown,
                                // rabbitGroupId: 1,
                                // regionId: 1,
                              ),
                            );
                      }
                    },
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
                ),
              );
          }
          return Scaffold(
            appBar: appBar,
            body: body,
          );
        },
      ),
    );
  }
}
