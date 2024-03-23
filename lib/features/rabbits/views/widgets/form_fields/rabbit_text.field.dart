import 'package:flutter/material.dart';

/// A custom text field widget with custom styling.
class RabbitTextField extends StatelessWidget {
  const RabbitTextField({
    super.key,
    required this.controller,
    required this.labelText,
    required this.hintText,
    required this.icon,
    this.validator,
  });

  final TextEditingController controller;
  final String labelText;
  final String hintText;
  final IconData icon;
  final String? Function(String?)? validator;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: labelText,
          hintText: hintText,
          border: const OutlineInputBorder(),
          prefixIcon: Icon(icon),
        ),
        validator: validator,
      ),
    );
  }
}
