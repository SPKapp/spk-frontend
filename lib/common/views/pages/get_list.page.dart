import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:spk_app_frontend/app/view/view.dart';
import 'package:spk_app_frontend/common/bloc/interfaces/get_list.bloc.interface.dart';
import 'package:spk_app_frontend/common/views/views.dart';

/// A page that fetches an object from the server and displays it
///
/// This view assumes that the [Bloc] is provided by the parent widget
///
class GetListPage<T extends Object, Args extends Object,
    Bloc extends IGetListBloc<T, Args>> extends StatelessWidget {
  const GetListPage({
    super.key,
    required this.title,
    required this.errorInfo,
    this.errorInfoBuilder,
    this.actions = const [],
    this.filterBuilder,
    this.floatingActionButton,
    this.emptyMessage,
    required this.itemBuilder,
  });

  /// The Title to display in the app bar
  final String title;

  /// The error info to display in the view
  /// If errorInfoBuilder is provided, this will be ignored in fetched state
  final String errorInfo;

  /// The builder function to build the error info with the current error code from cubit
  final String Function(BuildContext context, String errorCode)?
      errorInfoBuilder;

  /// The actions to display in the app bar
  final List<Widget> actions;

  /// The builder function to build the filter widget
  final Widget Function(
    BuildContext context,
    Args args,
    void Function(Args args) callback,
  )? filterBuilder;

  /// The floating action button to display in the view
  final Widget? floatingActionButton;

  /// The message to display when the list is empty
  final String? emptyMessage;

  /// The builder function to build the item widget
  final Widget Function(BuildContext context, T item) itemBuilder;

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<Bloc, GetListState<T>>(
      listener: (context, state) {
        if (state is GetListFailure && state.data.isNotEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                errorInfoBuilder != null
                    ? errorInfoBuilder!(context, (state as GetListFailure).code)
                    : errorInfo,
              ),
            ),
          );
        }
      },
      buildWhen: (previous, current) =>
          // TODO: Check if this is correct
          previous is! GetListSuccess || current is GetListSuccess,
      builder: (context, state) {
        late final Widget body;

        switch (state) {
          case GetListInitial():
            body = const InitialView();
          case GetListFailure():
            body = FailureView(
              message: errorInfoBuilder != null
                  ? errorInfoBuilder!(context, state.code)
                  : errorInfo,
              onPressed: () => context.read<Bloc>().add(const FetchList()),
            );
          case GetListSuccess():
            body = AppListView<T>(
              items: state.data,
              hasReachedMax: state.hasReachedMax,
              onRefresh: () async {
                // skip initial state
                Future bloc = context.read<Bloc>().stream.skip(1).first;
                context.read<Bloc>().add(RefreshList<Args>(null));
                return bloc;
              },
              onFetch: () {
                context.read<Bloc>().add(const FetchList());
              },
              emptyMessage: emptyMessage,
              itemBuilder: (T user) {
                return itemBuilder(context, user);
              },
            );
        }

        return Scaffold(
          drawer: const AppDrawer(),
          appBar: AppBar(
            leading:
                context.canPop() ? const BackButton() : const DrawerButton(),
            title: Text(title),
            actions: [
              ...actions,
              if (filterBuilder != null) _buidFilter(context),
            ],
          ),
          floatingActionButton: floatingActionButton,
          body: body,
        );
      },
    );
  }

  Widget _buidFilter(BuildContext context) {
    return IconButton(
      key: const Key('filterAction'),
      icon: const Icon(Icons.filter_alt),
      onPressed: () {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          builder: (_) {
            return BlocProvider.value(
              value: context.read<Bloc>(),
              child: FractionallySizedBox(
                widthFactor: 1.0,
                heightFactor: 0.7,
                child: SingleChildScrollView(
                  child: filterBuilder!(
                    context,
                    context.read<Bloc>().args,
                    (args) {
                      context.read<Bloc>().add(RefreshList(args));
                    },
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
