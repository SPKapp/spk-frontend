import 'package:go_router/go_router.dart';

import 'package:spk_app_frontend/example.dart';
import 'package:spk_app_frontend/example2.dart';
import 'package:spk_app_frontend/app/main_frame.dart';

final router = GoRouter(
  initialLocation: '/myRabbits',
  routes: [
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) =>
          MainFrame(navigationShell: navigationShell),
      branches: [
        StatefulShellBranch(routes: [
          GoRoute(
            path: '/myRabbits',
            builder: (context, state) => const MyHomePage(
              title: '/myRabbits',
            ),
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
