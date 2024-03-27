import 'package:flutter/material.dart';

/// A widget that represents a card in a list with nested list.
class ListCard extends StatelessWidget {
  const ListCard({
    super.key,
    required this.itemCount,
    required this.itemBuilder,
  });

  final int itemCount;
  final Widget? Function(BuildContext, int) itemBuilder;

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
          child: ListView.separated(
            itemCount: itemCount,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            separatorBuilder: (context, index) => const Divider(),
            itemBuilder: itemBuilder,
          ),
        ),
      ),
    );
  }
}
