import 'package:flutter/material.dart';

import 'package:spk_app_frontend/features/rabbits/models/rabbits_group.model.dart';
import 'package:spk_app_frontend/features/rabbits/views/widgets/rabbit_list_item.widget.dart';

class RabbitsGroupListItem extends StatelessWidget {
  const RabbitsGroupListItem({
    super.key,
    required this.rabbitsGroup,
  });

  final RabbitsGroup rabbitsGroup;

  @override
  Widget build(BuildContext context) {
    return Container(
        margin: const EdgeInsets.all(8.0),
        color: Colors.grey[200],
        child: Column(
          children: rabbitsGroup.rabbits
              .map((rabbit) => RabbitListItem(
                    id: rabbit.id,
                    name: rabbit.name,
                  ))
              .toList(),
        ));
  }
}
