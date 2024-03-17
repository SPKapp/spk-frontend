import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:spk_app_frontend/features/rabbits/bloc/rabbits.bloc.dart';
import 'package:spk_app_frontend/features/rabbits/views/widgets/rabbits_group_list_item.widget.dart';

class RabbitsListView extends StatefulWidget {
  const RabbitsListView({super.key});

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
    // if (_isBottom) context.read<RabbitsBloc>().add(RabbitsFeached());
  }

  bool get _isBottom {
    if (!_scrollController.hasClients) return false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    return currentScroll >= (maxScroll * 0.9);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RabbitsBloc, RabbitsState>(
      builder: (context, state) {
        switch (state.status) {
          case RabbitsStatus.failure:
            return const Center(child: Text('Failed to fetch rabbits'));
          case RabbitsStatus.success:
            if (state.rabbits.isEmpty) {
              return const Center(child: Text('No rabbits'));
            }
            return ListView.builder(
              itemBuilder: (BuildContext context, int index) {
                return index >= state.rabbits.length
                    ? Column(
                        children: [
                          TextButton(
                              onPressed: () => context.push('/myRabbits'),
                              child: const Text('NEW')),
                          TextButton(
                              onPressed: () => context.pop(),
                              child: const Text('BACK')),
                        ],
                      )
                    : RabbitsGroupListItem(
                        rabbitsGroup: state.rabbits[index],
                      );
              },
              itemCount: state.hasReachedMax
                  ? state.rabbits.length
                  : state.rabbits.length + 1,
              controller: _scrollController,
            );
          default:
            return const Center(child: CircularProgressIndicator());
        }
      },
    );
  }
}
