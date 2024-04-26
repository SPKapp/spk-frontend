import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spk_app_frontend/common/views/views.dart';
import 'package:spk_app_frontend/common/views/widgets/lists/list_card.widget.dart';

import 'package:spk_app_frontend/features/rabbits/bloc/rabbits_list.bloc.dart';
import 'package:spk_app_frontend/features/rabbits/models/models.dart';
import 'package:spk_app_frontend/features/rabbits/views/widgets/list_items.dart';

/// A widget that displays a list of rabbits.
///
/// This widget assumes that the [RabbitsListBloc] is already provided above in the widget tree.
/// If [rabbitGroups] is empty, it displays a message "Brak królików.".
/// If [hasReachedMax] is false, it displays a [CircularProgressIndicator] at the end of the list.
class RabbitsListView extends StatelessWidget {
  const RabbitsListView({
    super.key,
    required this.rabbitGroups,
    required this.hasReachedMax,
  });

  final List<RabbitGroup> rabbitGroups;
  final bool hasReachedMax;

  @override
  Widget build(BuildContext context) {
    return AppListView<RabbitGroup>(
      items: rabbitGroups,
      hasReachedMax: hasReachedMax,
      onRefresh: () async {
        // skip initial state
        Future bloc = context.read<RabbitsListBloc>().stream.skip(1).first;
        context.read<RabbitsListBloc>().add(const RefreshRabbits(null));
        return bloc;
      },
      onFetch: () {
        context.read<RabbitsListBloc>().add(const FetchRabbits());
      },
      emptyMessage: 'Brak królików.',
      itemBuilder: (dynamic rabbitGroup) => ListCard(
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
  }
}
