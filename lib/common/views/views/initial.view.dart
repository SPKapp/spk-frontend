import 'package:flutter/material.dart';

/// Widget that displays a loading indicator.
class InitialView extends StatelessWidget {
  const InitialView({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return const Center(child: CircularProgressIndicator());
  }
}
