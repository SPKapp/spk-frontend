import 'package:flutter/material.dart';

class RabbitNotesListPage extends StatelessWidget {
  const RabbitNotesListPage({
    super.key,
    required this.rabbitId,
    this.rabbitName,
    this.isVetVisit,
  });

  final int rabbitId;
  final String? rabbitName;
  final bool? isVetVisit;

  @override
  Widget build(BuildContext context) {
    // late Widget body;

    return Scaffold(
      appBar: AppBar(
        title: Text(rabbitName ?? 'Historia Notatek'),
      ),
      body: Center(
        child: Text(
            'Rabbit Notes List Page rabbitId: $rabbitId rabbitName: $rabbitName isVetVisit: $isVetVisit'),
      ),
    );
  }
}
