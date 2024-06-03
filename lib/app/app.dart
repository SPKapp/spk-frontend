import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:spk_app_frontend/app/router.dart';
import 'package:spk_app_frontend/app/view/inject_repositories.widget.dart';
import 'package:spk_app_frontend/common/bloc/theme.cubit.dart';
import 'package:spk_app_frontend/common/services/gql.service.dart';
import 'package:spk_app_frontend/config/config.dart';
import 'package:spk_app_frontend/features/auth/auth.dart';
import 'package:spk_app_frontend/features/auth/auth.service.dart';
import 'package:spk_app_frontend/features/notifications/notifications.dart';
import 'package:spk_app_frontend/features/notifications/repositories/interfaces.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      // Hydrated blocs
      providers: [
        BlocProvider<NotificationsCubit>(
          create: (_) => FcmTokenCubit(),
        ),
        BlocProvider(
          create: (_) => ThemeCubit(),
        ),
      ],
      child: InjectRepositories(
        child: MultiBlocProvider(
          providers: [
            RepositoryProvider<NotificationService>(
              create: (context) => NotificationService(
                fcmTokenCubit:
                    context.read<NotificationsCubit>() as FcmTokenCubit,
                fcmTokensRepository: context.read<IFcmTokensRepository>(),
              ),
            ),
            RepositoryProvider<AuthService>(
              create: (context) => AuthService(),
            ),
          ],
          child: BlocProvider(
            create: (context) {
              final cubit = AuthCubit(
                authService: context.read<AuthService>(),
                notificationService: context.read<NotificationService>(),
              );

              context
                  .read<GqlService>()
                  .setAuthToken(() => cubit.currentUser.token);
              return cubit;
            },
            child: BlocBuilder<ThemeCubit, ThemeMode>(
              builder: (context, themeMode) {
                AppRouter(context.read<AuthCubit>());
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
          ),
        ),
      ),
    );
  }
}
