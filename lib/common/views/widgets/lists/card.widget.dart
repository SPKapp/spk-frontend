import 'package:flutter/material.dart';

/// A widget that represents a card in a list.
class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 8.0,
        vertical: 4.0,
      ),
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2.0),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2.0),
          child: child,
        ),
      ),
    );
  }
}
