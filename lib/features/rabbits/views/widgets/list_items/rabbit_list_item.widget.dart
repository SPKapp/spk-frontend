import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// A widget that represents a single item in the rabbit list.
class RabbitListItem extends StatelessWidget {
  const RabbitListItem({
    super.key,
    required this.id,
    required this.name,
  });

  final String id;
  final String name;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.pets),
      title: Text(name, style: Theme.of(context).textTheme.titleLarge),
      onTap: () => context.push('/rabbit/$id'),
    );
  }
}
