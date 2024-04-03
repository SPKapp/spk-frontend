import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:spk_app_frontend/common/views/widgets/lists/card.widget.dart';

import 'package:spk_app_frontend/features/users/bloc/users_search.bloc.dart';
import 'package:spk_app_frontend/features/users/models/models.dart';

class UsersSearchView extends StatefulWidget {
  const UsersSearchView({
    super.key,
    required this.users,
    required this.hasReachedMax,
  });

  final List<User> users;
  final bool hasReachedMax;

  @override
  State<UsersSearchView> createState() => _UsersSearchViewState();
}

class _UsersSearchViewState extends State<UsersSearchView> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    SchedulerBinding.instance.addPostFrameCallback((duration) {
      if (!_scrollController.hasClients) return;

      final isScrollable = _scrollController.position.maxScrollExtent != 0;
      if (!isScrollable && !widget.hasReachedMax) {
        context.read<UsersSearchBloc>().add(const UsersSearchFetch());
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
      context.read<UsersSearchBloc>().add(const UsersSearchFetch());
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
    if (widget.users.isEmpty) {
      return const Center(
        child: Text('Brak wyników.'),
      );
    } else {
      return ListView.builder(
        key: const Key('usersSearchListView'),
        controller: _scrollController,
        itemCount: widget.users.length + (widget.hasReachedMax ? 0 : 1),
        itemBuilder: (context, index) {
          if (index >= widget.users.length) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final user = widget.users[index];
          return AppCard(
            child: TextButton(
              onPressed: () => context.push('/user/${user.id}'),
              child: Text(
                '${user.firstName} ${user.lastName}',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
          );
        },
      );
    }
  }
}
