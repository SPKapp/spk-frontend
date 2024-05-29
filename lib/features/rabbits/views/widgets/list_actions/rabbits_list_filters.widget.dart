import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';

import 'package:spk_app_frontend/features/rabbits/models/dto.dart';
import 'package:spk_app_frontend/features/rabbits/models/models.dart';

class RabbitsListFilters extends StatefulWidget {
  const RabbitsListFilters({
    super.key,
    required this.args,
    required this.onFilter,
  });

  final FindRabbitsArgs args;
  final Function(FindRabbitsArgs) onFilter;

  @override
  State<RabbitsListFilters> createState() => _RabbitsListFiltersState();
}

class _RabbitsListFiltersState extends State<RabbitsListFilters> {
  late FindRabbitsArgs args = widget.args;
  late Set<RabbitStatus> statusFilters =
      widget.args.rabbitStatus?.toSet() ?? RabbitStatus.active.toSet();

  @override
  Widget build(BuildContext context) {
    return Padding(
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
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text('Status królika'),
          ),
          Wrap(
            spacing: 5.0,
            alignment: WrapAlignment.center,
            children: RabbitStatus.statuses.map((type) {
              final selected = statusFilters.contains(type);
              return FilterChip(
                label: Text(type.displayName),
                selected: selected,
                showCheckmark: false,
                avatar: Icon(
                    selected ? FontAwesomeIcons.check : FontAwesomeIcons.xmark),
                onSelected: (bool selected) {
                  setState(() {
                    if (selected) {
                      statusFilters.add(type);
                    } else {
                      statusFilters.remove(type);
                    }
                  });
                },
              );
            }).toList(),
          ),
          FilledButton.tonal(
            onPressed: () {
              args = args.copyWith(
                rabbitStatus: () => statusFilters.toList(),
              );

              widget.onFilter(args);
              context.pop();
            },
            child: const Text('Filtruj'),
          ),
        ],
      ),
    );
  }
}
