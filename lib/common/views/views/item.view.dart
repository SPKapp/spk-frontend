import 'package:flutter/material.dart';

/// A widget providing a scrollable view with a refresh indicator.
class ItemView extends StatelessWidget {
  const ItemView({
    super.key,
    required this.child,
    required this.onRefresh,
  });

  final Widget child;

  /// A function that is called when the user pulls the refresh indicator.
  /// It should return a future that completes when the refresh is done.
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      return RefreshIndicator(
        onRefresh: onRefresh,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: child,
          ),
        ),
      );
    });
  }
}
