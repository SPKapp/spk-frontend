import 'package:flutter/material.dart';

class DateField extends StatelessWidget {
  const DateField({
    super.key,
    required this.controller,
    required this.labelText,
    required this.hintText,
    required this.icon,
    required this.onTap,
    this.daysBefore = 3650,
    this.daysAfter = 365,
  });

  final TextEditingController controller;
  final String labelText;
  final String hintText;
  final IconData icon;
  final void Function(DateTime) onTap;
  final int daysBefore;
  final int daysAfter;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextFormField(
        controller: controller,
        readOnly: true,
        decoration: InputDecoration(
          labelText: labelText,
          hintText: hintText,
          border: const OutlineInputBorder(),
          prefixIcon: Icon(icon),
        ),
        onTap: () async {
          final today = DateTime.now();
          final date = await showDatePicker(
            context: context,
            initialDate: today,
            firstDate: today.subtract(Duration(days: daysBefore)),
            lastDate: today.add(Duration(days: daysAfter)),
          );
          if (date != null) {
            onTap(date);
          }
        },
      ),
    );
  }
}
