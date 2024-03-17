import 'package:flutter/material.dart';

import 'package:spk_app_frontend/features/rabbits/views/volunteer/rabbits_list.page.dart';

class MyRabbitsPage extends StatelessWidget {
  const MyRabbitsPage({super.key, this.drawer});

  final Widget? drawer;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('My Rabbits'),
        ),
        drawer: drawer,
        body: const RabbitsListPage());
  }
}
