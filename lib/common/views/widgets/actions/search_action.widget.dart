import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:spk_app_frontend/common/bloc/interfaces/search.bloc.interface.dart';
import 'package:spk_app_frontend/common/views/views.dart';
import 'package:spk_app_frontend/common/views/widgets/actions/simple_search_action.widget.dart';

class SearchAction<T extends Object, Bloc extends ISearchBloc<T>>
    extends StatelessWidget {
  const SearchAction({
    super.key,
    this.errorInfo,
    this.errorInfoBuilder,
    required this.itemBuilder,
  }) : assert(errorInfo != null || errorInfoBuilder != null);

  /// The error info to display in the view
  /// If errorInfoBuilder is provided, this will be ignored in fetched state
  final String? errorInfo;

  /// The builder function to build the error info with the current error code from cubit
  final String Function(BuildContext context, String errorCode)?
      errorInfoBuilder;

  /// The builder function to build the item widget
  final Widget Function(BuildContext context, T item) itemBuilder;

  @override
  Widget build(BuildContext context) {
    return SimpleSearchAction(
      onClear: () {
        context.read<Bloc>().add(const ClearSearch());
      },
      generateResults: (_, query) {
        return BlocProvider.value(
          value: context.read<Bloc>(),
          child: BlocBuilder<Bloc, SearchState<T>>(
            builder: (context, state) {
              if (state.query != query) {
                context.read<Bloc>().add(RefreshSearch(query));
              }

              switch (state) {
                case SearchInitial():
                  // Results should be empty so we can return an empty container
                  return Container(
                    key: const Key('searchInitial'),
                  );
                case SearchFailure():
                  return FailureView(
                    message: errorInfoBuilder != null
                        ? errorInfoBuilder!(context, state.code)
                        : errorInfo!,
                    onPressed: () =>
                        context.read<Bloc>().add(const FetchSearch()),
                  );
                case SearchSuccess():
                  return AppListView<T>(
                    items: state.data,
                    hasReachedMax: state.hasReachedMax,
                    onRefresh: () async {},
                    onFetch: () {
                      context.read<Bloc>().add(const FetchSearch());
                    },
                    itemBuilder: (T item) => itemBuilder(context, item),
                  );
              }
            },
          ),
        );
      },
    );
  }
}
