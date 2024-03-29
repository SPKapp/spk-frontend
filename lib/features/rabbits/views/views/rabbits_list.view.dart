import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spk_app_frontend/common/views/widgets/lists/list_card.widget.dart';

import 'package:spk_app_frontend/features/rabbits/bloc/rabbits_list.bloc.dart';
import 'package:spk_app_frontend/features/rabbits/models/models.dart';
import 'package:spk_app_frontend/features/rabbits/views/widgets/list_items.dart';

/// A widget that displays a list of rabbits.
///
/// This widget assumes that the [RabbitsListBloc] is already provided above in the widget tree.
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
      context.read<RabbitsListBloc>().add(const FetchRabbits());
    }
  }

  bool get _isBottom {
    if (!_scrollController.hasClients) return false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    return currentScroll >= (maxScroll * 0.9);
  }

  @override
  Widget build(BuildContext context) => LayoutBuilder(
        builder: (context, constraints) => RefreshIndicator(
          onRefresh: () async {
            Future bloc = context.read<RabbitsListBloc>().stream.first;
            context.read<RabbitsListBloc>().add(const RefreshRabbits());
            return bloc;
          },
          child: Builder(builder: (context) {
            if (widget.rabbitsGroups.isEmpty) {
              return SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: const Center(
                    child: Text('Brak królików.'),
                  ),
                ),
              );
            }
            return ListView.builder(
              key: const Key('rabbitsListView'),
              controller: _scrollController,
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: widget.hasReachedMax
                  ? widget.rabbitsGroups.length
                  : widget.rabbitsGroups.length + 1,
              itemBuilder: (context, index) {
                if (index == widget.rabbitsGroups.length) {
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextButton(
                      onPressed: () => context
                          .read<RabbitsListBloc>()
                          .add(const FetchRabbits()),
                      child: const Center(child: CircularProgressIndicator()),
                    ),
                  );
                } else {
                  return ListCard(
                    itemCount: widget.rabbitsGroups[index].rabbits.length,
                    itemBuilder: (context, rabbitIndex) {
                      final rabbit =
                          widget.rabbitsGroups[index].rabbits[rabbitIndex];
                      return RabbitListItem(
                        id: rabbit.id,
                        name: rabbit.name,
                      );
                    },
                  );
                }
              },
            );
          }),
        ),
      );
}
