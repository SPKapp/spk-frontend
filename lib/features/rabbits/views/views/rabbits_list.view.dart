import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:spk_app_frontend/features/rabbits/bloc/rabbits.bloc.dart';
import 'package:spk_app_frontend/features/rabbits/models/models.dart';
import 'package:spk_app_frontend/features/rabbits/views/widgets/rabbit_list_item.widget.dart';

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
      return const Center(child: Text('No rabbits'));
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
            : _RabbitsGroupCard(rabbitsGroup: widget.rabbitsGroups[index]);
      },
    );
  }
}

class _RabbitsGroupCard extends StatelessWidget {
  const _RabbitsGroupCard({
    required this.rabbitsGroup,
  });

  final RabbitsGroup rabbitsGroup;

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
            itemCount: rabbitsGroup.rabbits.length,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            separatorBuilder: (context, index) => const Divider(),
            itemBuilder: (context, index) {
              return RabbitListItem(
                id: rabbitsGroup.rabbits[index].id,
                name: rabbitsGroup.rabbits[index].name,
              );
            },
          ),
        ),
      ),
    );
  }
}
