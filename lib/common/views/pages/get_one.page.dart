import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:spk_app_frontend/app/view/view.dart';

import 'package:spk_app_frontend/common/bloc/interfaces/get_one.cubit.interface.dart';
import 'package:spk_app_frontend/common/views/views.dart';

/// A page that fetches an object from the server and displays it
///
/// This view assumes that the [Cubit] is provided by the parent widget
///
class GetOnePage<T extends Object, Cubit extends IGetOneCubit<T>>
    extends StatelessWidget {
  const GetOnePage({
    super.key,
    required this.builder,
    required this.defaultTitle,
    this.titleBuilder,
    required this.errorInfo,
    this.errorInfoBuilder,
    this.actions,
    this.actionsBuilder,
    this.persistentFooterButtons,
    this.persistentFooterButtonsBuilder,
    this.refreshable = true,
  });

  /// The builder function to build the view with the fetched data
  final Widget Function(BuildContext context, T data) builder;

  /// The Title to display in the app bar
  /// If titleBuilder is provided, this will be ignored in fetched state
  final String defaultTitle;

  /// The builder function to build the title with the fetched data
  final String Function(BuildContext context, T data)? titleBuilder;

  /// The error info to display in the view
  /// If errorInfoBuilder is provided, this will be ignored in fetched state
  final String errorInfo;

  /// The builder function to build the error info with the current error code from cubit
  final String Function(BuildContext context, String errorCode)?
      errorInfoBuilder;

  /// The actions to display in the app bar
  /// If actionsBuilder is provided, this will be ignored in fetched state
  final List<Widget>? actions;

  /// The builder function to build the actions with the fetched data
  final List<Widget>? Function(BuildContext context, T data)? actionsBuilder;

  /// The persistent footer buttons to display in the view
  /// If persistentFooterButtonsBuilder is provided, this will be ignored in fetched state
  final List<Widget>? persistentFooterButtons;

  /// The builder function to build the persistent footer buttons with the fetched data
  final List<Widget>? Function(BuildContext context, T data)?
      persistentFooterButtonsBuilder;

  /// Whether the view should be refreshable
  final bool refreshable;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<Cubit, GetOneState<T>>(
      builder: (context, state) {
        String title = defaultTitle;
        List<Widget>? actions = this.actions;
        List<Widget>? footerButtons = persistentFooterButtons;
        late final Widget body;

        switch (state) {
          case GetOneInitial():
            body = const InitialView();
          case GetOneFailure():
            body = FailureView(
              message: errorInfoBuilder != null
                  ? errorInfoBuilder!(context, state.code)
                  : errorInfo,
              onPressed: () => context.read<Cubit>().fetch(),
            );
          case GetOneSuccess():
            if (titleBuilder != null) {
              title = titleBuilder!(context, state.data);
            }
            if (actionsBuilder != null) {
              actions = actionsBuilder!(context, state.data);
            }
            if (persistentFooterButtonsBuilder != null) {
              footerButtons =
                  persistentFooterButtonsBuilder!(context, state.data);
            }
            body = refreshable
                ? ItemView(
                    onRefresh: () async {
                      Future cubit = context.read<Cubit>().stream.skip(1).first;
                      context.read<Cubit>().refresh();
                      return cubit;
                    },
                    child: builder(context, state.data),
                  )
                : builder(context, state.data);
        }

        return Scaffold(
          drawer: const AppDrawer(),
          appBar: AppBar(
            leading:
                context.canPop() ? const BackButton() : const DrawerButton(),
            title: Text(title),
            actions: actions,
          ),
          body: body,
          persistentFooterAlignment: AlignmentDirectional.bottomCenter,
          persistentFooterButtons: footerButtons,
        );
      },
    );
  }
}
