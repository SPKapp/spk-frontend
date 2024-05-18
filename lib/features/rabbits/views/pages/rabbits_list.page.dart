import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:spk_app_frontend/common/bloc/interfaces/get_list.bloc.interface.dart';
import 'package:spk_app_frontend/common/views/pages/get_list.page.dart';
import 'package:spk_app_frontend/common/views/widgets/lists/list_card.widget.dart';
import 'package:spk_app_frontend/features/auth/auth.dart';

import 'package:spk_app_frontend/features/rabbits/bloc/rabbits_list.bloc.dart';
import 'package:spk_app_frontend/features/rabbits/models/dto.dart';
import 'package:spk_app_frontend/features/rabbits/models/models.dart';
import 'package:spk_app_frontend/features/rabbits/repositories/interfaces.dart';
import 'package:spk_app_frontend/features/rabbits/views/widgets/list_actions.dart';
import 'package:spk_app_frontend/features/rabbits/views/widgets/list_items.dart';

/// A page that displays a list of rabbits.
///
/// This widget assumes that the [IRabbitsRepository] is provided above by [RepositoryProvider].
class RabbitsListPage extends StatelessWidget {
  const RabbitsListPage({
    super.key,
    this.rabbitsListBloc,
    this.volunteerView = true,
  });

  final RabbitsListBloc Function(BuildContext)? rabbitsListBloc;
  final bool volunteerView;

  @override
  Widget build(BuildContext context) {
    final teamIds = volunteerView &&
            context.read<AuthCubit>().currentUser.checkRole([Role.volunteer])
        ? [context.read<AuthCubit>().currentUser.teamId!]
        : null;

    final canCreate = context
        .read<AuthCubit>()
        .currentUser
        .checkRole([Role.admin, Role.regionManager]);

    return BlocProvider(
      create: rabbitsListBloc ??
          (context) => RabbitsListBloc(
                rabbitsRepository: context.read<IRabbitsRepository>(),
                args: FindRabbitsArgs(
                  teamsIds: teamIds?.map((e) => e.toString()).toList(),
                ),
              )..add(const FetchList()),
      child: Builder(builder: (context) {
        return GetListPage<RabbitGroup, FindRabbitsArgs, RabbitsListBloc>(
          title: volunteerView ? 'Moje Króliki' : 'Króliki',
          errorInfo: 'Wystąpił błąd podczas pobierania królików.',
          actions: [
            RabbitsSearchAction(
              key: const Key('searchAction'),
              args: context.read<RabbitsListBloc>().args,
            ),
          ],
          filterBuilder: (context, args, callback) => RabbitsListFilters(
            args: args,
            onFilter: callback,
          ),
          emptyMessage: 'Brak królików.',
          floatingActionButton: !volunteerView && canCreate
              ? FloatingActionButton(
                  key: const Key('addRabbitButton'),
                  onPressed: () {
                    context.push('/rabbit/add');
                  },
                  child: const Icon(Icons.add),
                )
              : null,
          itemBuilder: (context, rabbitGroup) => ListCard(
            itemCount: rabbitGroup.rabbits.length,
            itemBuilder: (context, index) {
              final rabbit = rabbitGroup.rabbits[index];
              return RabbitListItem(
                id: rabbit.id,
                name: rabbit.name,
              );
            },
          ),
        );
      }),
    );
  }
}
