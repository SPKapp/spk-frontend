import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spk_app_frontend/common/bloc/theme.cubit.dart';
import 'package:spk_app_frontend/common/views/widgets/lists/card.widget.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({
    super.key,
    required this.drawer,
  });

  final Widget? drawer;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeCubit, ThemeMode>(
      builder: (context, themeMode) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Ustawienia'),
          ),
          drawer: drawer,
          body: Center(
            child: AppCard(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                    title: Text(
                      'Motyw',
                      style: Theme.of(context).textTheme.titleLarge,
                      textAlign: TextAlign.center,
                    ),
                  ),
                  RadioListTile(
                    key: const Key('systemButton'),
                    title: const Text('Systemowy'),
                    value: ThemeMode.system,
                    groupValue: themeMode,
                    onChanged: (ThemeMode? value) {
                      context.read<ThemeCubit>().updateTheme(value!);
                    },
                  ),
                  RadioListTile(
                    key: const Key('lightButton'),
                    title: const Text('Jasny'),
                    value: ThemeMode.light,
                    groupValue: themeMode,
                    onChanged: (ThemeMode? value) {
                      context.read<ThemeCubit>().updateTheme(value!);
                    },
                  ),
                  RadioListTile(
                    key: const Key('darkButton'),
                    title: const Text('Ciemny'),
                    value: ThemeMode.dark,
                    groupValue: themeMode,
                    onChanged: (ThemeMode? value) {
                      context.read<ThemeCubit>().updateTheme(value!);
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
