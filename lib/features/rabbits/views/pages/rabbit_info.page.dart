import 'package:flutter/material.dart';

class RabbitInfo extends StatelessWidget {
  const RabbitInfo({
    super.key,
    required this.id,
  });

  final int id;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Rabbit Info'),
        ),
        body: Placeholder(
          child: Text('id: $id'),
        ));
  }
}
