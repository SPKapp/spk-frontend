import 'package:flutter/material.dart';

import 'package:spk_app_frontend/features/rabbits/models/models.dart';
import 'package:spk_app_frontend/features/rabbits/views/widgets/list_items/rabbit_list_item.widget.dart';

/// A widget that represents a card for displaying a group of rabbits.
class RabbitGroupCard extends StatelessWidget {
  const RabbitGroupCard({
    super.key,
    required this.rabbitsGroup,
  });

  final RabbitsGroup rabbitsGroup;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 8.0,
        vertical: 4.0,
      ),
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2.0),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2.0),
          child: ListView.separated(
            itemCount: rabbitsGroup.rabbits.length,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            separatorBuilder: (context, index) => const Divider(),
            itemBuilder: (context, index) {
              return RabbitListItem(
                id: rabbitsGroup.rabbits[index].id,
                name: rabbitsGroup.rabbits[index].name,
              );
            },
          ),
        ),
      ),
    );
  }
}
