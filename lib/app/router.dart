import 'package:go_router/go_router.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart';

import 'package:spk_app_frontend/app/view/view.dart';

import 'package:spk_app_frontend/example2.dart';
import 'package:spk_app_frontend/features/rabbits/views/volunteer/rabbits_list.page.dart';

final router = GoRouter(
  initialLocation: '/myRabbits',
  routes: [
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) => AuthGate(
        unauthChild: const SignInScreen(
          showAuthActionSwitch: false,
          email: 'tester2@example.com', // TODO: Remove testing data
        ),
        child: InjectRepositories(
          child: ScaffoldWithNavigation(
            navigationShell: navigationShell,
          ),
        ),
      ),
      branches: [
        StatefulShellBranch(routes: [
          GoRoute(
            path: '/myRabbits',
            builder: (context, state) => const RabbitsListPage(),
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
