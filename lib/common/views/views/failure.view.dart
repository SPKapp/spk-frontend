import 'package:flutter/material.dart';

/// A view that represents a failure state.
///
/// This view displays a [message] and an optional button to retry the operation.
class FailureView extends StatelessWidget {
  const FailureView({
    super.key,
    required this.message,
    this.onPressed,
  });

  final String message;
  final void Function()? onPressed;

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
          if (onPressed != null) ...[
            const SizedBox(
              height: 8,
            ),
            FilledButton.tonal(
              onPressed: onPressed,
              child: const Text('Spróbuj ponownie'),
            ),
          ]
        ],
      ),
    );
  }
}
