import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:spk_app_frontend/common/views/views.dart';

import 'package:spk_app_frontend/common/views/widgets/lists/list_card.widget.dart';

import 'package:spk_app_frontend/features/users/bloc/users_list.bloc.dart';
import 'package:spk_app_frontend/features/users/models/models.dart';

/// A widget that displays a scrollable list of users.
///
/// This widget assumes that the [UsersListBloc] is already provided above in the widget tree.
/// If [teams] is empty, it displays a message "Brak użytkowników.".
/// If [hasReachedMax] is false, it displays a [CircularProgressIndicator] at the end of the list.
class UsersListView extends StatelessWidget {
  const UsersListView({
    super.key,
    required this.teams,
    required this.hasReachedMax,
  });

  final List<Team> teams;
  final bool hasReachedMax;

  @override
  Widget build(BuildContext context) {
    return AppListView(
      items: teams,
      hasReachedMax: hasReachedMax,
      onRefresh: () async {
        // skip initial state
        Future bloc = context.read<UsersListBloc>().stream.skip(1).first;
        context.read<UsersListBloc>().add(const RefreshUsers());
        return bloc;
      },
      onFetch: () {
        context.read<UsersListBloc>().add(const FetchUsers());
      },
      emptyMessage: 'Brak użytkowników.',
      itemBuilder: (dynamic team) => ListCard(
        itemCount: team.users.length,
        itemBuilder: (context, index) {
          final user = team.users[index];
          return ListTile(
            leading: const Icon(Icons.person),
            onTap: () => context.push('/user/${user.id}'),
            title: Text(
              '${user.firstName} ${user.lastName}',
            ),
            subtitle: // TODO: Add role
                const Text('Rola'),
          );
        },
      ),
    );
  }
}

// class _UsersListViewState extends State<UsersListView> {
//   final _scrollController = ScrollController();

//   @override
//   void initState() {
//     super.initState();
//     _scrollController.addListener(_onScroll);
//   }

//   @override
//   void dispose() {
//     _scrollController
//       ..removeListener(_onScroll)
//       ..dispose();
//     super.dispose();
//   }

//   void _onScroll() {
//     if (_isBottom) {
//       context.read<UsersListBloc>().add(const FetchUsers());
//     }
//   }

//   bool get _isBottom {
//     if (!_scrollController.hasClients) return false;
//     final maxScroll = _scrollController.position.maxScrollExtent;
//     final currentScroll = _scrollController.offset;
//     return currentScroll >= (maxScroll * 0.9);
//   }

//   @override
//   Widget build(BuildContext context) => LayoutBuilder(
//         builder: (context, constraints) => RefreshIndicator(
//           onRefresh: () async {
//             Future bloc = context.read<UsersListBloc>().stream.first;
//             context.read<UsersListBloc>().add(const RefreshUsers());
//             return bloc;
//           },
//           child: Builder(builder: (context) {
//             if (widget.teams.isEmpty) {
//               return SingleChildScrollView(
//                 physics: const AlwaysScrollableScrollPhysics(),
//                 child: ConstrainedBox(
//                   constraints: BoxConstraints(minHeight: constraints.maxHeight),
//                   child: const Center(
//                     child: Text('Brak użytkowników.'),
//                   ),
//                 ),
//               );
//             }

//             return ListView.builder(
//               key: const Key('usersListView'),
//               controller: _scrollController,
//               physics: const AlwaysScrollableScrollPhysics(),
//               itemCount: widget.hasReachedMax
//                   ? widget.teams.length
//                   : widget.teams.length + 1,
//               itemBuilder: (context, index) {
//                 if ((index == widget.teams.length)) {
//                   return Padding(
//                     padding: const EdgeInsets.all(8.0),
//                     child: TextButton(
//                       onPressed: () =>
//                           context.read<UsersListBloc>().add(const FetchUsers()),
//                       child: const Center(child: CircularProgressIndicator()),
//                     ),
//                   );
//                 } else {
//                   return ListCard(
//                     itemCount: widget.teams[index].users.length,
//                     itemBuilder: (context, userIndex) {
//                       final user = widget.teams[index].users[userIndex];
//                       return ListTile(
//                         leading: const Icon(Icons.person),
//                         onTap: () => context.push('/user/${user.id}'),
//                         title: Text(
//                           '${user.firstName} ${user.lastName}',
//                         ),
//                         subtitle: // TODO: Add role
//                             const Text('Rola'),
//                       );
//                     },
//                   );
//                 }
//               },
//             );
//           }),
//         ),
//       );
// }
