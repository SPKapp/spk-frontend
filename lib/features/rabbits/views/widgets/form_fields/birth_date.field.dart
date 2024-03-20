import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class BirthDateField extends StatelessWidget {
  const BirthDateField({
    super.key,
    required this.controller,
    required this.onTap,
    required this.onConfirmedBirthDate,
    required this.confirmedBirthDate,
  });

  final TextEditingController controller;
  final void Function(DateTime date) onTap;
  final void Function() onConfirmedBirthDate;
  final bool confirmedBirthDate;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextFormField(
        controller: controller,
        readOnly: true,
        decoration: InputDecoration(
          labelText: 'Data urodzenia',
          hintText: 'Podaj datę urodzenia królika',
          border: const OutlineInputBorder(),
          prefixIcon: const Icon(FontAwesomeIcons.calendarDay),
          suffix: TextButton(
            onPressed: onConfirmedBirthDate,
            child: Text(
              confirmedBirthDate ? 'Dokładna data' : 'Przybliżona data',
            ),
          ),
        ),
        onTap: () async {
          final today = DateTime.now();
          final date = await showDatePicker(
            context: context,
            initialDate: today,
            firstDate: today.subtract(const Duration(days: 36500)),
            lastDate: today,
          );
          if (date != null) {
            onTap(date);
          }
        },
      ),
    );
  }
}
