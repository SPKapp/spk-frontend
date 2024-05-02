import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:spk_app_frontend/common/views/views.dart';
import 'package:spk_app_frontend/features/auth/auth.dart';

import 'package:spk_app_frontend/features/rabbits/bloc/rabbit_create.cubit.dart';
import 'package:spk_app_frontend/features/rabbits/models/dto.dart';
import 'package:spk_app_frontend/features/rabbits/repositories/interfaces.dart';
import 'package:spk_app_frontend/features/rabbits/views/views/rabbit_modify.view.dart';

import 'package:spk_app_frontend/features/regions/bloc/regions_list.bloc.dart';
import 'package:spk_app_frontend/features/regions/models/models.dart';
import 'package:spk_app_frontend/features/regions/repositories/interfaces.dart';

class RabbitCreatePage extends StatefulWidget {
  const RabbitCreatePage({
    super.key,
    this.rabbitCreateCubit,
    this.regionsListBloc,
  });

  final RabbitCreateCubit Function(BuildContext)? rabbitCreateCubit;
  final RegionsListBloc Function(BuildContext)? regionsListBloc;

  @override
  State<RabbitCreatePage> createState() => _RabbitCreatePageState();
}

class _RabbitCreatePageState extends State<RabbitCreatePage> {
  final _formKey = GlobalKey<FormState>();
  final _editControlers = FieldControlers();

  @override
  void dispose() {
    _editControlers.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: widget.rabbitCreateCubit ??
          (context) => RabbitCreateCubit(
                rabbitsRepository: context.read<IRabbitsRepository>(),
              ),
      child: Builder(builder: (context) {
        final currentUser = context.read<AuthCubit>().currentUser;

        if (currentUser.checkRole([Role.admin]) ||
            currentUser.managerRegions!.length > 1) {
          return BlocProvider(
            create: widget.regionsListBloc ??
                (context) => RegionsListBloc(
                      regionsRepository: context.read<IRegionsRepository>(),
                      perPage: 0,
                    )..add(const FetchRegions()),
            child: BlocBuilder<RegionsListBloc, RegionsListState>(
              builder: (context, state) {
                switch (state) {
                  case RegionsListInitial():
                    return const InitialView();
                  case RegionsListFailure():
                    return FailureView(
                      message: 'Nie udało się pobrać regionów',
                      onPressed: () => context
                          .read<RegionsListBloc>()
                          .add(const RefreshRegions()),
                    );
                  case RegionsListSuccess():
                    return _buildForm(context, regions: state.regions);
                }
              },
            ),
          );
        } else {
          _editControlers.selectedRegion =
              Region(id: currentUser.managerRegions!.first);
          return Builder(
            builder: (context) => _buildForm(context),
          );
        }
      }),
    );
  }

  void _onSubmit(BuildContext context) {
    if (_formKey.currentState!.validate()) {
      context.read<RabbitCreateCubit>().createRabbit(
            RabbitCreateDto(
              name: _editControlers.nameControler.text,
              color: _editControlers.colorControler.text.isNotEmpty
                  ? _editControlers.colorControler.text
                  : null,
              breed: _editControlers.breedControler.text.isNotEmpty
                  ? _editControlers.breedControler.text
                  : null,
              gender: _editControlers.selectedGender,
              birthDate: (_editControlers.birthDateControler.text.isNotEmpty)
                  ? DateTime.parse(_editControlers.birthDateControler.text)
                  : null,
              confirmedBirthDate: _editControlers.confirmedBirthDate,
              admissionDate: (_editControlers
                      .admissionDateControler.text.isNotEmpty)
                  ? DateTime.parse(_editControlers.admissionDateControler.text)
                  : null,
              admissionType: _editControlers.selectedAdmissionType,
              fillingDate: (_editControlers.filingDateControler.text.isNotEmpty)
                  ? DateTime.parse(_editControlers.filingDateControler.text)
                  : null,
              regionId: _editControlers.selectedRegion?.id,
            ),
          );
    }
  }

  Widget _buildForm(BuildContext context, {List<Region>? regions}) {
    return BlocListener<RabbitCreateCubit, RabbitCreateState>(
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
      child: Scaffold(
        appBar: AppBar(
          actions: [
            IconButton(
              icon: const Icon(Icons.send_rounded),
              onPressed: () => _onSubmit(context),
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
            privileged: true,
            regions: regions,
          ),
        ),
      ),
    );
  }
}
