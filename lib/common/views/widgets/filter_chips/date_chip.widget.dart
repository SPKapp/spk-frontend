import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'package:spk_app_frontend/common/extensions/extensions.dart';

class DateChip extends StatelessWidget {
  const DateChip({
    super.key,
    required this.date,
    required this.onDateChanged,
    this.emptyText = 'Wybierz datę',
    this.filledText,
    this.icon = FontAwesomeIcons.calendarDay,
    this.firstDate,
    this.lastDate,
  });

  final DateTime? date;
  final void Function(DateTime?) onDateChanged;
  final String emptyText;
  final String? filledText;
  final IconData icon;
  final DateTime? firstDate;
  final DateTime? lastDate;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(7.0),
      child: InputChip(
        label: Text(date != null
            ? filledText ?? 'Data: ${date?.toDateString() ?? ''}'
            : emptyText),
        avatar: Icon(icon),
        showCheckmark: false,
        selected: date != null,
        onSelected: (bool _) async {
          final resultDate = await showDatePicker(
            context: context,
            initialDate: date ?? DateTime.now(),
            firstDate: firstDate ?? DateTime(2020),
            lastDate: lastDate ?? DateTime.now().add(const Duration(days: 365)),
          );

          onDateChanged(resultDate);
        },
        onDeleted: date != null ? () => onDateChanged(null) : null,
      ),
    );
  }
}
