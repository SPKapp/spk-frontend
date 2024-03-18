import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:spk_app_frontend/app/router.dart';
import 'package:spk_app_frontend/app/bloc/app.bloc.dart';
import 'package:spk_app_frontend/app/view/inject_repositories.widget.dart';
import 'package:spk_app_frontend/features/auth/auth.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AppBloc(authService: AuthService()),
      child: BlocListener<AppBloc, AppState>(
          listener: (BuildContext context, AppState state) {
            AppRouter.router.refresh();
          },
          child: InjectRepositories(
            child: MaterialApp.router(
              title: 'Flutter Demo',
              theme: ThemeData.dark(
                // This is the theme of your application.
                //
                // TRY THIS: Try running your application with "flutter run". You'll see
                // the application has a purple toolbar. Then, without quitting the app,
                // try changing the seedColor in the colorScheme below to Colors.green
                // and then invoke "hot reload" (save your changes or press the "hot
                // reload" button in a Flutter-supported IDE, or press "r" if you used
                // the command line to start the app).
                //
                // Notice that the counter didn't reset back to zero; the application
                // state is not lost during the reload. To reset the state, use hot
                // restart instead.
                //
                // This works for code too, not just values: Most code changes can be
                // tested with just a hot reload.
                // colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
                useMaterial3: true,
              ),
              routerConfig: AppRouter.router,
            ),
          )),
    );
  }
}
