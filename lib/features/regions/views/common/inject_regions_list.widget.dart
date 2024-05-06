import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spk_app_frontend/common/views/views.dart';

import 'package:spk_app_frontend/features/regions/bloc/regions_list.bloc.dart';
import 'package:spk_app_frontend/features/regions/models/models.dart';
import 'package:spk_app_frontend/features/regions/repositories/interfaces.dart';

class InjectRegionsList extends StatelessWidget {
  const InjectRegionsList({
    super.key,
    this.regionsListBloc,
    required this.builder,
    this.regionsIds,
  });

  final RegionsListBloc Function(BuildContext)? regionsListBloc;
  final Widget Function(BuildContext, List<Region> regions) builder;
  final Iterable<String>? regionsIds;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: regionsListBloc ??
          (context) => RegionsListBloc(
                // TODO: Add selectedRegions to RegionsListBloc
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
                onPressed: () =>
                    context.read<RegionsListBloc>().add(const RefreshRegions()),
              );
            case RegionsListSuccess():
              return builder(context, state.regions);
          }
        },
      ),
    );
  }
}
