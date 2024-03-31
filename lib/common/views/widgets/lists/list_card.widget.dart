import 'package:flutter/material.dart';

import 'package:spk_app_frontend/common/views/widgets/lists/card.widget.dart';

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
    return AppCard(
        child: ListView.separated(
      itemCount: itemCount,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      separatorBuilder: (context, index) => const Divider(),
      itemBuilder: itemBuilder,
    ));
  }
}
