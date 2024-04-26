import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:spk_app_frontend/features/auth/auth.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final currentUser = context.read<AuthCubit>().currentUser;

    final List<Widget> regionManagerList = [
      const Center(child: Text('RegionManager')),
      ListTile(
        title: const Text('Króliki'),
        onTap: () => context.go('/rabbits'),
      ),
      ListTile(
        title: const Text('Dodaj królika'),
        onTap: () => context.push('/rabbit/add'),
      ),
      ListTile(
        title: const Text('Dodaj użytkownika'),
        onTap: () => context.push('/user/add'),
      ),
      const Divider()
    ];

    final List<Widget> adminList = regionManagerList;

    final List<Widget> volunteerList = [
      const Center(child: Text('Wolontariusz')),
      ListTile(
        title: const Text('Moje Króliki'),
        onTap: () => context.go('/myRabbits'),
      ),
      const Divider()
    ];

    return Drawer(
      child: ListView(
        children: <Widget>[
          const DrawerHeader(
            decoration: BoxDecoration(
                // color: Colors.blue,
                ),
            child: Text('Drawer Header'),
          ),

          ListTile(
            title: const Text('Wyloguj się'),
            onTap: () => context.read<AuthCubit>().logout(),
          ),
          if (currentUser.checkRole([Role.volunteer])) ...volunteerList,
          if (currentUser.checkRole([Role.admin]))
            ...adminList
          else if (currentUser.checkRole([Role.regionManager]))
            ...regionManagerList,
          // const AboutListTile(),
        ],
      ),
    );
  }
}
