import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:spk_app_frontend/features/rabbits/bloc/rabbits.bloc.dart';
import 'package:spk_app_frontend/features/rabbits/models/models.dart';
import 'package:spk_app_frontend/features/rabbits/views/widgets/list_items.dart';

/// A widget that displays a list of rabbits.
///
/// If [rabbitsGroups] is empty, it displays a message "Brak królików.".
/// If [hasReachedMax] is false, it displays a [CircularProgressIndicator] at the end of the list.
class RabbitsListView extends StatefulWidget {
  const RabbitsListView(
      {super.key, required this.rabbitsGroups, required this.hasReachedMax});

  final List<RabbitsGroup> rabbitsGroups;
  final bool hasReachedMax;

  @override
  State<RabbitsListView> createState() => _RabbitsListViewState();
}

class _RabbitsListViewState extends State<RabbitsListView> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_isBottom) {
      context.read<RabbitsBloc>().add(const FeatchRabbits());
    }
  }

  bool get _isBottom {
    if (!_scrollController.hasClients) return false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    return currentScroll >= (maxScroll * 0.9);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.rabbitsGroups.isEmpty) {
      return const Center(child: Text('Brak królików.'));
    }

    return ListView.builder(
      controller: _scrollController,
      itemCount: widget.hasReachedMax
          ? widget.rabbitsGroups.length
          : widget.rabbitsGroups.length + 1,
      itemBuilder: (context, index) {
        return (index == widget.rabbitsGroups.length)
            ? const Padding(
                padding: EdgeInsets.all(8.0),
                child: Center(child: CircularProgressIndicator()),
              )
            : RabbitGroupCard(rabbitsGroup: widget.rabbitsGroups[index]);
      },
    );
  }
}
