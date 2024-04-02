import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:spk_app_frontend/common/views/widgets/lists/card.widget.dart';

import 'package:spk_app_frontend/features/rabbits/bloc/rabbits_search.bloc.dart';
import 'package:spk_app_frontend/features/rabbits/models/models.dart';

class RabbitsSearchView extends StatefulWidget {
  const RabbitsSearchView({
    super.key,
    required this.rabbits,
    required this.hasReachedMax,
  });

  final List<Rabbit> rabbits;
  final bool hasReachedMax;

  @override
  State<RabbitsSearchView> createState() => _RabbitsSearchViewState();
}

class _RabbitsSearchViewState extends State<RabbitsSearchView> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    SchedulerBinding.instance.addPostFrameCallback((duration) {
      if (!_scrollController.hasClients) return;

      final isScrollable = _scrollController.position.maxScrollExtent != 0;
      if (!isScrollable && !widget.hasReachedMax) {
        context.read<RabbitsSearchBloc>().add(const RabbitsSearchFetch());
      }
    });
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
      context.read<RabbitsSearchBloc>().add(const RabbitsSearchFetch());
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
    if (widget.rabbits.isEmpty) {
      return const Center(
        child: Text('Brak wyników.'),
      );
    } else {
      return ListView.builder(
        key: const Key('rabbitsSearchListView'),
        controller: _scrollController,
        itemCount: widget.rabbits.length + (widget.hasReachedMax ? 0 : 1),
        itemBuilder: (context, index) {
          if (index >= widget.rabbits.length) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else {
            final rabbit = widget.rabbits[index];
            return AppCard(
              child: TextButton(
                onPressed: () => context.push('/rabbit/${rabbit.id}'),
                child: Text(
                  rabbit.name,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
            );
          }
        },
      );
    }
  }
}
