import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:spk_app_frontend/features/rabbits/bloc/rabbit_create.cubit.dart';
import 'package:spk_app_frontend/features/rabbits/models/dto.dart';
import 'package:spk_app_frontend/features/rabbits/repositories/interfaces.dart';
import 'package:spk_app_frontend/features/rabbits/views/views/rabbit_modify.view.dart';

class RabbitAddPage extends StatefulWidget {
  const RabbitAddPage({
    super.key,
  });

  @override
  State<RabbitAddPage> createState() => _RabbitAddPageState();
}

class _RabbitAddPageState extends State<RabbitAddPage> {
  final _formKey = GlobalKey<FormState>();
  final FieldControlers _editControlers = FieldControlers();

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => RabbitCreateCubit(
        rabbitsRepository: context.read<IRabbitsRepository>(),
      ),
      child: Builder(builder: (context) {
        return Scaffold(
          appBar: AppBar(
            actions: [
              BlocListener<RabbitCreateCubit, RabbitCreateState>(
                listener: (context, state) {
                  switch (state) {
                    case RabbitCreated():
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Królik został dodany'),
                        ),
                      );
                      context.pushReplacement('/rabbit/${state.rabbitId}');
                      break;
                    case RabbitCreateFailure():
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Nie udało się dodać królika'),
                        ),
                      );
                    default:
                  }
                },
                child: IconButton(
                  icon: const Icon(Icons.send_rounded),
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      context.read<RabbitCreateCubit>().createRabbit(
                            RabbitCreateDto(
                              name: _editControlers.nameControler.text,
                              color:
                                  _editControlers.colorControler.text.isNotEmpty
                                      ? _editControlers.colorControler.text
                                      : null,
                              breed:
                                  _editControlers.breedControler.text.isNotEmpty
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
                                  ? DateTime.parse(
                                      _editControlers.filingDateControler.text)
                                  : null,
                              // status: Status.unknown,
                              // rabbitGroupId: 1,
                              // regionId: 1,
                            ),
                          );
                    }
                  },
                ),
              ),
            ],
            title: const Text(
              'Dodaj królika',
            ),
          ),
          body: Form(
            key: _formKey,
            child: RabbitModifyView(
              editControlers: _editControlers,
            ),
          ),
        );
      }),
    );
  }
}
