import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:spk_app_frontend/common/views/widgets/lists/card.widget.dart';

import 'package:spk_app_frontend/features/rabbits/models/models.dart';

/// A widget that represents a card displaying names of conected rabbits.
///
/// This widget is used to display information about a group of rabbits that are friends.
/// This widget is used in the [RabbitInfoView] widget.
class RabbitGroupCard extends StatelessWidget {
  const RabbitGroupCard({
    super.key,
    required this.rabbits,
  });

  final Iterable<Rabbit> rabbits;

  @override
  Widget build(BuildContext context) {
    return AppCard(
        child: Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            rabbits.length > 1
                ? 'Zaprzyjaźnione Króliki:'
                : 'Zaprzyjaźniony Królik:',
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
        ...ListTile.divideTiles(
          context: context,
          tiles: rabbits
              .map(
                (rabbit) => ListTile(
                  title: Text(rabbit.name),
                  leading: const Icon(Icons.pets),
                  onTap: () => context.push('/rabbit/${rabbit.id}'),
                ),
              )
              .toList(),
        ),
      ],
    ));
  }
}
