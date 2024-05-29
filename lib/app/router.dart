import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart';

import 'package:spk_app_frontend/app/view/view.dart';
import 'package:spk_app_frontend/common/views/pages.dart';

import 'package:spk_app_frontend/example2.dart';
import 'package:spk_app_frontend/features/adoption/views/pages.dart';
import 'package:spk_app_frontend/features/auth/auth.dart';
import 'package:spk_app_frontend/features/rabbit-notes/views/pages.dart';
import 'package:spk_app_frontend/features/rabbits/views/pages.dart';
import 'package:spk_app_frontend/features/users/views/pages.dart';

class AppRouter {
  static GoRouter router = GoRouter(
    redirect: _authGuard,
    routes: [
      GoRoute(
        path: '/signIn',
        redirect: _signInRedirect,
        builder: (context, state) => const SignInScreen(
          showAuthActionSwitch: false,
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
          StatefulShellBranch(
            routes: [
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
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/example',
                builder: (context, state) => const MyHomePage2(),
              ),
            ],
          ),
        ],
      ),
    ],
  );

  static String? _authGuard(BuildContext context, GoRouterState state) {
    switch (context.read<AuthCubit>().state) {
      case Authenticated():
        return null;
      case Unauthenticated():
        return '/signIn';
    }
  }

  static String? _signInRedirect(BuildContext context, GoRouterState state) {
    switch (context.read<AuthCubit>().state) {
      case Authenticated():
        return '/';
      case Unauthenticated():
        return null;
    }
  }
}
