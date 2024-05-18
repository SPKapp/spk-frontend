import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:spk_app_frontend/common/bloc/interfaces/get_list.bloc.interface.dart';
import 'package:spk_app_frontend/common/views/views/get_list.view.dart';
import 'package:spk_app_frontend/features/regions/bloc/regions_list.bloc.dart';
import 'package:spk_app_frontend/features/regions/models/dto.dart';
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
                regionsRepository: context.read<IRegionsRepository>(),
                args: FindRegionsArgs(
                  limit: 0,
                  regionsIds: regionsIds,
                ),
              )..add(const FetchList()),
      child: GetListView<Region, FindRegionsArgs, RegionsListBloc>(
        errorInfo: 'Nie udało się pobrać listy regionów.',
        builder: builder,
      ),
    );
  }
}
