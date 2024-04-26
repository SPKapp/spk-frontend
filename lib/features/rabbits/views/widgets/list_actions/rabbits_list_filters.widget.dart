import 'package:flutter/material.dart';

import 'package:spk_app_frontend/features/rabbits/models/dto.dart';

class RabbitsListFilters extends StatefulWidget {
  const RabbitsListFilters({
    super.key,
    required this.args,
  });

  final FindRabbitsArgs args;

  @override
  State<RabbitsListFilters> createState() => _RabbitsListFiltersState();
}

class _RabbitsListFiltersState extends State<RabbitsListFilters> {
  late FindRabbitsArgs args = widget.args;

  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      widthFactor: 1.0,
      heightFactor: 0.7,
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  'Filtruj króliki',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              const Placeholder(
                  // TODO: Implement filters
                  ),
              FilledButton.tonal(
                onPressed: () {},
                child: const Text('Filtruj'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
