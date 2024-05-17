import 'package:flutter/material.dart';
import 'dart:async';

/// A widget providing a scrollable view with a refresh indicator
/// and fetching more items when reaching the bottom of the list.
class AppListView<T> extends StatefulWidget {
  const AppListView({
    super.key,
    required this.items,
    required this.hasReachedMax,
    required this.onRefresh,
    required this.onFetch,
    String? emptyMessage,
    required this.itemBuilder,
  }) : emptyMessage = emptyMessage ?? 'Brak wyników.';

  final List<T> items;
  final bool hasReachedMax;
  final Future<void> Function() onRefresh;
  final void Function() onFetch;
  final String emptyMessage;
  final Widget Function(T item) itemBuilder;

  @override
  State<AppListView> createState() => _AppListViewState<T>();
}

class _AppListViewState<T> extends State<AppListView<T>> {
  final _scrollController = ScrollController();
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);

    // If screen is not scrollable, fetch next pages
    if (!widget.hasReachedMax) {
      _timer = Timer.periodic(const Duration(milliseconds: 501), (timer) {
        if (!widget.hasReachedMax &&
            _scrollController.hasClients &&
            _scrollController.position.maxScrollExtent == 0.0) {
          widget.onFetch();
        } else {
          timer.cancel();
        }
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_isBottom) {
      widget.onFetch();
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
    return LayoutBuilder(builder: (context, constraints) {
      return RefreshIndicator(
        onRefresh: widget.onRefresh,
        child: Builder(builder: (context) {
          if (widget.items.isEmpty) {
            return SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Center(
                  child: Text(widget.emptyMessage),
                ),
              ),
            );
          }
          return ListView.builder(
              key: const Key('appListView'),
              controller: _scrollController,
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: widget.items.length + (widget.hasReachedMax ? 0 : 1),
              itemBuilder: (context, index) {
                if (index >= widget.items.length) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }
                return widget.itemBuilder(widget.items[index]);
              });
        }),
      );
    });
  }
}
