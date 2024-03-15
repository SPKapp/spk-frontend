import 'package:flutter/material.dart';

class RabbitListItem extends StatelessWidget {
  const RabbitListItem({
    super.key,
    required this.id,
    required this.name,
  });

  final id;
  final name;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.pets),
      title: Text(name),
      subtitle: Text(id.toString()),
    );
  }
}
