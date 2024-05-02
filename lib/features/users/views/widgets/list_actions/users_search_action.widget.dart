import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:spk_app_frontend/common/views/views.dart';
import 'package:spk_app_frontend/common/views/widgets/actions.dart';
import 'package:spk_app_frontend/common/views/widgets/lists/card.widget.dart';
import 'package:spk_app_frontend/features/users/bloc/users_search.bloc.dart';
import 'package:spk_app_frontend/features/users/models/dto/find_users.args.dart';
import 'package:spk_app_frontend/features/users/models/models.dart';
import 'package:spk_app_frontend/features/users/repositories/interfaces.dart';

class UsersSearchAction extends StatelessWidget {
  const UsersSearchAction({
    super.key,
    required this.args,
    this.usersSearchBloc,
  });

  final FindUsersArgs args;
  final UsersSearchBloc Function(BuildContext)? usersSearchBloc;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: usersSearchBloc ??
          (context) => UsersSearchBloc(
                usersRepository: context.read<IUsersRepository>(),
                args: args,
              ),
      child: Builder(builder: (context) {
        return SearchAction(
          onClear: () =>
              context.read<UsersSearchBloc>().add(const UsersSearchClear()),
          generateResults: (generateContext, query) {
            return BlocProvider.value(
              value: context.read<UsersSearchBloc>(),
              child: BlocBuilder<UsersSearchBloc, UsersSearchState>(
                  builder: (context, state) {
                if (state.query != query) {
                  context
                      .read<UsersSearchBloc>()
                      .add(UsersSearchRefresh(query));
                }
                switch (state) {
                  case UsersSearchInitial():
                    return Container(
                      key: const Key('searchInitial'),
                    );
                  case UsersSearchFailure():
                    return const FailureView(
                      message:
                          'Wystąpił błąd podczas wyszukiwania użytkowników.',
                    );
                  case UsersSearchSuccess():
                    return AppListView<User>(
                      items: state.users,
                      hasReachedMax: state.hasReachedMax,
                      onRefresh: () async {},
                      onFetch: () {
                        context
                            .read<UsersSearchBloc>()
                            .add(const UsersSearchFetch());
                      },
                      itemBuilder: (dynamic user) {
                        return AppCard(
                          child: TextButton(
                            onPressed: () =>
                                context.push('/user/${(user as User).id}'),
                            child: Text(
                              user.fullName,
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                          ),
                        );
                      },
                    );
                  default:
                    return Container();
                }
              }),
            );
          },
        );
      }),
    );
  }
}
