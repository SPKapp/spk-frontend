import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'package:spk_app_frontend/features/rabbits/models/models.dart';

/// A dropdown widget for selecting the gender of a rabbit.
class GenderDropdown extends StatelessWidget {
  const GenderDropdown({
    super.key,
    required this.onSelected,
    this.initialSelection = Gender.unknown,
  });

  final void Function(Gender?)? onSelected;
  final Gender initialSelection;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: LayoutBuilder(
        builder: (context, constraints) => DropdownMenu<Gender>(
          label: const Text('Płeć'),
          leadingIcon: const Icon(FontAwesomeIcons.venusMars),
          width: constraints.maxWidth,
          onSelected: onSelected,
          initialSelection: initialSelection,
          dropdownMenuEntries: const [
            DropdownMenuEntry(
              value: Gender.female,
              label: 'Samiczka',
            ),
            DropdownMenuEntry(
              value: Gender.male,
              label: 'Samiec',
            ),
            DropdownMenuEntry(
              value: Gender.unknown,
              label: 'Nieznana',
            ),
          ],
        ),
      ),
    );
  }
}
