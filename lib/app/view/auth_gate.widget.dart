import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:spk_app_frontend/app/bloc/app.bloc.dart';
import 'package:spk_app_frontend/features/auth/auth.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({
    super.key,
    required this.child,
    required this.unauthChild,
  });

  final Widget child;
  final Widget unauthChild;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
        create: (_) => AppBloc(authService: AuthService()),
        child: BlocBuilder<AppBloc, AppState>(
          builder: (BuildContext context, AppState state) {
            switch (state.status) {
              case AppStatus.authenticated:
                return child;
              case AppStatus.unauthenticated:
                return unauthChild;
            }
          },
        ));
  }
}
