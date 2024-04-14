import 'package:flutter/material.dart';

// TODO: Implement this widget
class WeightHistory extends StatelessWidget {
  const WeightHistory({
    super.key,
    required this.rabbitId,
  });

  final int rabbitId;

  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      widthFactor: 1.0,
      heightFactor: 0.85,
      child: ListView.builder(
        itemCount: 20,
        itemBuilder: (context, index) => const Center(
          child: Padding(
            padding: EdgeInsets.all(8.0),
            child: Text('Tutaj będzie historia wagi'),
          ),
        ),
      ),
    );
  }
}
