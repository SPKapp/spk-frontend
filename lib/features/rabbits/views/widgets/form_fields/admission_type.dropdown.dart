import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'package:spk_app_frontend/features/rabbits/models/models.dart';

/// A dropdown widget for selecting the admission type.
class AdmissionTypeDropdown extends StatelessWidget {
  const AdmissionTypeDropdown({
    super.key,
    required this.onSelected,
    this.initialSelection = AdmissionType.found,
  });

  final void Function(AdmissionType?)? onSelected;
  final AdmissionType initialSelection;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: LayoutBuilder(
        builder: (context, constraints) => DropdownMenu<AdmissionType>(
          label: const Text('Status przyjęcia'),
          leadingIcon: const Icon(FontAwesomeIcons.doorOpen),
          width: constraints.maxWidth,
          onSelected: onSelected,
          initialSelection: initialSelection,
          dropdownMenuEntries: [
            DropdownMenuEntry(
                value: AdmissionType.found,
                label: AdmissionType.found.toHumanReadable()),
            DropdownMenuEntry(
                value: AdmissionType.handedOver,
                label: AdmissionType.handedOver.toHumanReadable()),
            DropdownMenuEntry(
                value: AdmissionType.returned,
                label: AdmissionType.returned.toHumanReadable()),
          ],
        ),
      ),
    );
  }
}
