import 'package:flutter/material.dart';

class FailureView extends StatelessWidget {
  const FailureView({
    super.key,
    required this.message,
    required this.onPressed,
  });

  final String message;
  final void Function() onPressed;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            message,
            textAlign: TextAlign.center,
          ),
          const SizedBox(
            height: 8,
          ),
          FilledButton.tonal(
            onPressed: onPressed,
            child: const Text('Spróbuj ponownie'),
          ),
        ],
      ),
    );
  }
}
