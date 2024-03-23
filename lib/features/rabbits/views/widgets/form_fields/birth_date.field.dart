import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

/// A widget that represents a form field for entering a birth date.
class BirthDateField extends StatefulWidget {
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
  State<BirthDateField> createState() => _BirthDateFieldState();
}

class _BirthDateFieldState extends State<BirthDateField> {
  late bool _confirmedBirthDate = widget.confirmedBirthDate;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextFormField(
        controller: widget.controller,
        readOnly: true,
        decoration: InputDecoration(
          labelText: 'Data urodzenia',
          hintText: 'Podaj datę urodzenia królika',
          border: const OutlineInputBorder(),
          prefixIcon: const Icon(FontAwesomeIcons.calendarDay),
          suffix: TextButton(
            onPressed: () {
              setState(() {
                _confirmedBirthDate = !_confirmedBirthDate;
              });
              widget.onConfirmedBirthDate();
            },
            child: Text(
              _confirmedBirthDate ? 'Dokładna data' : 'Przybliżona data',
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
            widget.onTap(date);
          }
        },
      ),
    );
  }
}
