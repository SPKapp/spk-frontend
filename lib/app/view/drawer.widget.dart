import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';

import 'package:spk_app_frontend/features/auth/auth.dart';
import 'package:spk_app_frontend/features/auth/views/widgets/change_password.widget.dart';

class AppDrawer extends StatefulWidget {
  const AppDrawer({super.key});

  @override
  State<AppDrawer> createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  bool isAccountDrawer = false;

  @override
  Widget build(BuildContext context) {
    final currentUser = context.read<AuthCubit>().currentUser;

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          UserAccountsDrawerHeader(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.outline,
            ),
            accountName: Text(currentUser.name ?? ''),
            accountEmail: Text(currentUser.email ?? ''),
            onDetailsPressed: () {
              setState(() {
                isAccountDrawer = !isAccountDrawer;
              });
            },
          ),
          if (isAccountDrawer) ...accountDrawer(context),
          if (!isAccountDrawer) ...defaultDrawer(context, currentUser),
        ],
      ),
    );
  }

  Iterable<Widget> defaultDrawer(
      BuildContext context, CurrentUser currentUser) {
    final List<Widget> regionObserverList = [
      ListTile(
        title: const Text('Króliki'),
        onTap: () => context.go('/rabbits'),
      ),
    ];

    final List<Widget> regionManagerList = [
      ...regionObserverList,
      ListTile(
        title: const Text('Użytkownicy'),
        onTap: () => context.go('/users'),
      ),
    ];

    final List<Widget> adminList = regionManagerList;

    return [
      if (currentUser.checkRole([Role.volunteer])) ...[
        const Center(child: Text('Wolontariusz')),
        ListTile(
          title: const Text('Moje Króliki'),
          onTap: () => context.go('/myRabbits'),
        ),
        const Divider()
      ],
      if (currentUser.checkRole([Role.admin])) ...[
        const Center(child: Text('Admin')),
        ...adminList
      ] else if (currentUser.checkRole([Role.regionManager])) ...[
        const Center(child: Text('Manager Regionu')),
        ...regionManagerList,
      ] else if (currentUser.checkRole([Role.regionRabbitObserver])) ...[
        const Center(child: Text('Obserwator Regionu')),
        ...regionObserverList,
      ],
      const Divider(),
      ListTile(
        title: const Text('Ustawienia'),
        onTap: () => context.go('/settings'),
      ),
    ];
  }

  Iterable<Widget> accountDrawer(BuildContext context) {
    return [
      ListTile(
        title: const Text('Moje Konto'),
        leading: const Icon(FontAwesomeIcons.user),
        onTap: () => context.go('/myProfile'),
      ),
      ListTile(
        title: const Text('Zmień Hasło'),
        leading: const Icon(FontAwesomeIcons.lock),
        onTap: () async {
          await showModalBottomSheet<bool>(
            context: context,
            isScrollControlled: true,
            builder: (_) => const ChangePasswordAction(),
          );
        },
      ),
      ListTile(
        title: const Text('Wyloguj się'),
        leading: const Icon(FontAwesomeIcons.rightFromBracket),
        onTap: () => context.read<AuthCubit>().logout(),
      ),
    ];
  }
}
