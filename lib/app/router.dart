import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart';

import 'package:spk_app_frontend/app/bloc/app.bloc.dart';
import 'package:spk_app_frontend/app/view/view.dart';

import 'package:spk_app_frontend/example2.dart';
import 'package:spk_app_frontend/features/rabbits/views/pages/pages.dart';

class AppRouter {
  static GoRouter router = GoRouter(
    initialLocation: '/myRabbits',
    redirect: _authGuard,
    routes: [
      GoRoute(
        path: '/signIn',
        redirect: _signInRedirect,
        builder: (context, state) => const SignInScreen(
          showAuthActionSwitch: false,
          email: 'tester2@example.com', // TODO: Remove testing data
        ),
      ),
      GoRoute(
        path: '/',
        redirect: (context, state) => '/myRabbits',
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) => ScaffoldWithNavigation(
          navigationShell: navigationShell,
        ),
        branches: [
          StatefulShellBranch(routes: [
            GoRoute(
              path: '/myRabbits',
              builder: (context, state) => const MyRabbitsPage(
                drawer: Drawer(
                  child: Placeholder(),
                ),
              ),
            ),
            GoRoute(
              path: '/rabbit',
              redirect: (context, state) => '/', // TODO: Redirect where?
              routes: [
                GoRoute(
                  path: ':id',
                  builder: (context, state) {
                    return RabbitInfo(
                      id: int.parse(state.pathParameters['id']!),
                    );
                  },
                ),
              ],
            ),
          ]),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/myProfile',
                builder: (context, state) => const MyHomePage2(),
              ),
            ],
          ),
        ],
      ),
    ],
  );

  static String? _authGuard(BuildContext context, GoRouterState state) {
    final authStatus = context.read<AppBloc>().state.status;

    switch (authStatus) {
      case AppStatus.authenticated:
        return null;
      case AppStatus.unauthenticated:
        return '/signIn';
    }
  }

  static String? _signInRedirect(BuildContext context, GoRouterState state) {
    final authStatus = context.read<AppBloc>().state.status;

    switch (authStatus) {
      case AppStatus.authenticated:
        return '/';
      case AppStatus.unauthenticated:
        return null;
    }
  }
}
