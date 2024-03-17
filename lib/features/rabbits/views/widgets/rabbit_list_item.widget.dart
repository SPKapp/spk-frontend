import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class RabbitListItem extends StatelessWidget {
  const RabbitListItem({
    super.key,
    required this.id,
    required this.name,
  });

  final int id;
  final String name;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.pets),
      title: Text(name),
      subtitle: Text(id.toString()),
      onTap: () => context.push('/rabbit/$id'),
    );
  }
}
