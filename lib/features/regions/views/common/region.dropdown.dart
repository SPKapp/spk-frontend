import 'package:flutter/material.dart';

import 'package:spk_app_frontend/features/regions/models/models.dart';

class RegionDropdown extends StatelessWidget {
  const RegionDropdown({
    super.key,
    this.onSelected,
    required this.regions,
  });

  final void Function(Region?)? onSelected;
  final List<Region> regions;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: LayoutBuilder(
          builder: (context, constraints) => DropdownMenu<Region>(
                label: const Text('Region'),
                width: constraints.maxWidth,
                onSelected: onSelected,
                dropdownMenuEntries: regions
                    .map(
                      (region) => DropdownMenuEntry(
                        value: region,
                        label: region.name ?? 'id: ${region.id}',
                      ),
                    )
                    .toList(),
              )),
    );
  }
}
