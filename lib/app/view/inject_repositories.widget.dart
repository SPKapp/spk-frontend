import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:spk_app_frontend/common/services/gql.service.dart';
import 'package:spk_app_frontend/features/auth/auth.dart';
import 'package:spk_app_frontend/features/rabbit-notes/repositories/interfaces.dart';
import 'package:spk_app_frontend/features/rabbit-notes/repositories/repositories.dart';
import 'package:spk_app_frontend/features/rabbits/repositories/interfaces.dart';
import 'package:spk_app_frontend/features/rabbits/repositories/repositories.dart';
import 'package:spk_app_frontend/features/regions/repositories/interfaces.dart';
import 'package:spk_app_frontend/features/regions/repositories/repositories.dart';
import 'package:spk_app_frontend/features/users/repositories/interfaces.dart';
import 'package:spk_app_frontend/features/users/repositories/repositories.dart';

class InjectRepositories extends StatelessWidget {
  const InjectRepositories({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final gqlService =
        GqlService(() => context.read<AuthCubit>().currentUser.token);

    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<IRabbitsRepository>(
          create: (context) => RabbitsRepository(gqlService),
        ),
        RepositoryProvider<IRabbitGroupsRepository>(
          create: (context) => RabbitGroupsRepository(gqlService),
        ),
        RepositoryProvider<IUsersRepository>(
          create: (context) => UsersRepository(gqlService),
        ),
        RepositoryProvider<ITeamsRepository>(
          create: (context) => TeamsReposiotry(gqlService),
        ),
        RepositoryProvider<IPermissionsRepository>(
          create: (context) => PermissionsRepository(gqlService),
        ),
        RepositoryProvider<IRegionsRepository>(
          create: (context) => RegionsRepository(gqlService),
        ),
        RepositoryProvider<IRabbitNotesRepository>(
          create: (context) => GqlRabbitNotesRepository(gqlService),
        ),
      ],
      child: child,
    );
  }
}
