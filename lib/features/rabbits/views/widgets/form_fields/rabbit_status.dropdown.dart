import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'package:spk_app_frontend/features/rabbits/models/models.dart';

class RabbitStatusDropdown extends StatelessWidget {
  const RabbitStatusDropdown(
      {super.key,
      required this.onSelected,
      this.initialSelection = RabbitStatus.unknown});

  final void Function(RabbitStatus?)? onSelected;
  final RabbitStatus initialSelection;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: LayoutBuilder(
        builder: (context, constraints) => DropdownMenu<RabbitStatus>(
          label: const Text('Status królika'),
          leadingIcon: const Icon(FontAwesomeIcons.flagCheckered),
          width: constraints.maxWidth,
          onSelected: onSelected,
          initialSelection: initialSelection,
          dropdownMenuEntries: const [
            DropdownMenuEntry(value: RabbitStatus.unknown, label: 'Nieznany'),
            DropdownMenuEntry(
                value: RabbitStatus.forCastration, label: 'Do kastracji'),
          ],
        ),
      ),
    );
  }
}
