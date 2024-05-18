import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spk_app_frontend/common/bloc/interfaces/get_list.bloc.interface.dart';
import 'package:spk_app_frontend/common/views/views.dart';

/// A view that fetches a list of objects from the server and displays it
/// This view assumes that the [Bloc] is provided by the parent widget
class GetListView<T extends Object, Args extends Object,
    Bloc extends IGetListBloc<T, Args>> extends StatelessWidget {
  const GetListView({
    super.key,
    this.errorInfo,
    this.errorInfoBuilder,
    required this.builder,
  }) : assert(
          errorInfo != null || errorInfoBuilder != null,
          'errorInfo or errorInfoBuilder must be provided',
        );

  /// The error info to display in the view
  /// If errorInfoBuilder is provided, this will be ignored
  /// else this must be provided
  final String? errorInfo;

  /// The builder function to build the error info with the current error code from cubit
  final String Function(BuildContext context, String errorCode)?
      errorInfoBuilder;

  /// The builder function to build the view with the fetched data
  final Widget Function(BuildContext context, List<T> data) builder;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<Bloc, GetListState<T>>(
      builder: (context, state) {
        switch (state) {
          case GetListInitial():
            return const InitialView();
          case GetListFailure():
            return FailureView(
              message: errorInfoBuilder != null
                  ? errorInfoBuilder!(context, state.code)
                  : errorInfo!,
              onPressed: () => context.read<Bloc>().add(const FetchList()),
            );
          case GetListSuccess():
            return builder(context, state.data);
        }
      },
    );
  }
}
