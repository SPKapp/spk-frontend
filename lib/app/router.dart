import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart';

import 'package:spk_app_frontend/app/view/view.dart';
import 'package:spk_app_frontend/common/views/pages.dart';
import 'package:spk_app_frontend/config/auth.config.dart';

import 'package:spk_app_frontend/features/adoption/views/pages.dart';
import 'package:spk_app_frontend/features/auth/auth.dart';
import 'package:spk_app_frontend/features/rabbit-notes/views/pages.dart';
import 'package:spk_app_frontend/features/rabbit_photos/views/pages.dart';
import 'package:spk_app_frontend/features/rabbits/views/pages.dart';
import 'package:spk_app_frontend/features/users/views/pages.dart';

class AppRouter {
  AppRouter(AuthCubit authCubit) {
    _router ??= GoRouter(
      routes: _routes,
      redirect: _authGuard,
      refreshListenable: _GoRouterRefreshStream(authCubit.stream),
    );
  }

  static GoRouter get router {
    if (_router == null) {
      throw Exception('AppRouter not initialized');
    }
    return _router!;
  }

  static GoRouter? _router;

  static final _routes = [
    GoRoute(
      path: '/signIn',
      redirect: _signInRedirect,
      builder: (context, state) => SignInScreen(
        showAuthActionSwitch: false,
        actions: [
          ForgotPasswordAction((context, email) {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => ForgotPasswordScreen(
                  email: email,
                  // WARNING: Normally ForgotPasswordScreen don't have this prop
                  // I will create a new PR in firebase_ui_auth to add this prop
                  actionCodeSettings: AuthConfig.actionCodeSettings,
                ),
              ),
            );
          }),
        ],
      ),
    ),
    GoRoute(
      path: '/',
      redirect: (context, state) => '/myRabbits',
    ),
    // StatefulShellRoute.indexedStack(
    //   builder: (context, state, navigationShell) => ScaffoldWithNavigation(
    //     navigationShell: navigationShell,
    //   ),
    //   branches: [
    //     StatefulShellBranch(
    //       routes: [
    GoRoute(
        path: '/myRabbits',
        builder: (context, state) {
          return const RabbitsListPage(
            volunteerView: true,
          );
        }),
    GoRoute(
        path: '/rabbits',
        builder: (context, state) {
          return const RabbitsListPage(
            volunteerView: false,
          );
        }),
    GoRoute(
      path: '/rabbit/add',
      builder: (context, state) {
        return const RabbitCreatePage();
      },
    ),
    GoRoute(
      path: '/rabbit/:id',
      builder: (context, state) {
        final extra = state.extra as dynamic;
        final query = state.uri.queryParameters;

        final launchSetStatusAction =
            query['launchSetStatusAction'] == 'true' ||
                extra?['launchSetStatusAction'] == true;

        return RabbitInfoPage(
          key: ValueKey(state.pathParameters['id']),
          rabbitId: state.pathParameters['id']!,
          launchSetStatusAction: launchSetStatusAction,
        );
      },
      routes: [
        GoRoute(
          path: 'photos',
          builder: (context, state) {
            final extra = state.extra as dynamic;

            return RabbitPhotosListPage(
                key: ValueKey(state.pathParameters['id']),
                rabbitId: state.pathParameters['id']!,
                rabbitName: extra?['rabbitName']);
          },
        ),
        GoRoute(
          path: 'edit',
          builder: (context, state) {
            return RabbitUpdatePage(
              key: ValueKey(state.pathParameters['id']),
              rabbitId: state.pathParameters['id']!,
            );
          },
        ),
        GoRoute(
          path: 'notes',
          builder: (context, state) {
            final extra = state.extra as dynamic;

            return RabbitNotesListPage(
                key: ValueKey(state.pathParameters['id']),
                rabbitId: state.pathParameters['id']!,
                rabbitName: extra?['rabbitName'],
                isVetVisit: extra?['isVetVisit']);
          },
        ),
        GoRoute(
          path: 'note/create',
          builder: (context, state) {
            final extra = state.extra as dynamic;

            return RabbitNoteCreatePage(
              key: ValueKey(state.pathParameters['id']),
              rabbitId: state.pathParameters['id']!,
              isVetVisitInitial: extra?['isVetVisit'],
              rabbitName: extra?['rabbitName'],
            );
          },
        ),
      ],
    ),
    GoRoute(
      path: '/rabbitGroup/:id',
      builder: (context, state) {
        final extra = state.extra as dynamic;
        final query = state.uri.queryParameters;

        final launchSetAdoptedAction =
            query['launchSetAdoptedAction'] == 'true' ||
                extra?['launchSetAdoptedAction'] == true;

        return AdoptionInfoPage(
          key: ValueKey(state.pathParameters['id']),
          rabbitGroupId: state.pathParameters['id']!,
          launchSetAdoptedAction: launchSetAdoptedAction,
        );
      },
      routes: [
        GoRoute(
          path: 'edit',
          builder: (context, state) {
            return UpdateAdoptionInfoPage(
              key: ValueKey(state.pathParameters['id']),
              rabbitGroupId: state.pathParameters['id']!,
            );
          },
        ),
      ],
    ),
    GoRoute(
      path: '/note/:id',
      builder: (context, state) {
        final extra = state.extra as dynamic;

        return RabbitNotePage(
          key: ValueKey(state.pathParameters['id']),
          id: state.pathParameters['id']!,
          rabbitName: extra?['rabbitName'],
        );
      },
      routes: [
        GoRoute(
          path: 'edit',
          builder: (context, state) {
            return RabbitNoteUpdatePage(
              key: ValueKey(state.pathParameters['id']),
              rabbitNoteId: state.pathParameters['id']!,
            );
          },
        ),
      ],
    ),
    GoRoute(
      path: '/users',
      builder: (context, state) {
        return const UsersListPage();
      },
    ),
    GoRoute(
      path: '/user/add',
      builder: (context, state) {
        return const UserCreatePage();
      },
    ),
    GoRoute(
      path: '/user/:id',
      builder: (context, state) {
        return UserPage(
          key: ValueKey(state.pathParameters['id']),
          userId: state.pathParameters['id']!,
        );
      },
      routes: [
        GoRoute(
          path: 'edit',
          builder: (context, state) {
            return UserUpdatePage(
              key: ValueKey(state.pathParameters['id']),
              userId: state.pathParameters['id']!,
            );
          },
        ),
      ],
    ),
    GoRoute(
      path: '/myProfile',
      builder: (context, state) {
        return const MyProfilePage();
      },
      routes: [
        GoRoute(
          path: 'edit',
          builder: (context, state) {
            return const UserUpdatePage();
          },
        ),
      ],
    ),
    GoRoute(
      path: '/settings',
      builder: (context, state) => const SettingsPage(
        drawer: AppDrawer(),
      ),
    ),
    //       ],
    //     ),
    //     StatefulShellBranch(
    //       routes: [
    //         GoRoute(
    //           path: '/example',
    //           builder: (context, state) => const MyHomePage2(),
    //         ),
    //       ],
    //     ),
    //   ],
    // ),
  ];

  static String? _authGuard(BuildContext context, GoRouterState state) {
    switch (context.read<AuthCubit>().state) {
      case Authenticated():
        return null;
      case Unauthenticated():
        if (state.uri.path == '/signIn') {
          return null;
        }
        return '/signIn?redirect=${state.uri}';
    }
  }

  static String? _signInRedirect(BuildContext context, GoRouterState state) {
    switch (context.read<AuthCubit>().state) {
      case Authenticated():
        if (state.uri.queryParameters['redirect'] != null) {
          return state.uri.queryParameters['redirect'];
        } else {
          return '/';
        }
      case Unauthenticated():
        return null;
    }
  }
}

class _GoRouterRefreshStream extends ChangeNotifier {
  _GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen(
          (dynamic _) => notifyListeners(),
        );
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
