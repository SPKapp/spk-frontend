import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:spk_app_frontend/app/router.dart';
import 'package:spk_app_frontend/app/view/inject_repositories.widget.dart';
import 'package:spk_app_frontend/common/bloc/theme.cubit.dart';
import 'package:spk_app_frontend/config/config.dart';
import 'package:spk_app_frontend/features/auth/auth.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => AuthCubit(),
        ),
        BlocProvider(
          create: (_) => ThemeCubit(),
        ),
      ],
      child: BlocListener<AuthCubit, AuthState>(
          listener: (BuildContext context, AuthState state) {
        AppRouter.router.refresh();
      }, child: InjectRepositories(
        child: BlocBuilder<ThemeCubit, ThemeMode>(
          builder: (context, themeMode) {
            return MaterialApp.router(
              title: AppConfig.appName,
              themeMode: themeMode,
              theme: ThemeData.light(
                useMaterial3: true,
              ),
              darkTheme: ThemeData.dark(
                useMaterial3: true,
              ),
              routerConfig: AppRouter.router,
            );
          },
        ),
      )),
    );
  }
}
