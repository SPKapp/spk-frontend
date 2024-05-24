import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:spk_app_frontend/common/views/pages/get_one.page.dart';
import 'package:spk_app_frontend/common/views/widgets/actions.dart';
import 'package:spk_app_frontend/features/auth/auth.dart';

import 'package:spk_app_frontend/features/rabbits/bloc/rabbit.cubit.dart';
import 'package:spk_app_frontend/features/rabbits/models/models.dart';
import 'package:spk_app_frontend/features/rabbits/repositories/interfaces.dart';
import 'package:spk_app_frontend/features/rabbits/views/views/rabbit_info.view.dart';
import 'package:spk_app_frontend/features/rabbits/views/widgets/rabbit_info_actions.dart';

/// A page that displays information about a rabbit.
///
/// This widget assumes that the [IRabbitsRepository] is provided above by [RepositoryProvider].
class RabbitInfoPage extends StatelessWidget {
  const RabbitInfoPage({
    super.key,
    required this.rabbitId,
    this.rabbitCubit,
  });

  final String rabbitId;
  final RabbitCubit Function(BuildContext)? rabbitCubit;

  @override
  Widget build(BuildContext context) {
    final user = context.read<AuthCubit>().currentUser;
    final isAtLeastRegionManager =
        user.checkRole([Role.regionManager, Role.admin]);

    return BlocProvider(
      create: rabbitCubit ??
          (context) => RabbitCubit(
                rabbitsRepository: context.read<IRabbitsRepository>(),
                rabbitId: rabbitId,
              )..fetch(),
      child: GetOnePage<Rabbit, RabbitCubit>(
          defaultTitle: 'Królik',
          titleBuilder: (context, rabbit) => rabbit.name,
          errorInfo: 'Nie udało się pobrać królika',
          actionsBuilder: (context, rabbit) {
            if (isAtLeastRegionManager ||
                (user.checkRole([Role.volunteer]) &&
                    user.checkTeamId(
                        int.tryParse(rabbit.rabbitGroup?.team?.id ?? '')))) {
              return [
                IconButton(
                  key: const Key('rabbit_info_edit_button'),
                  icon: const Icon(Icons.edit),
                  onPressed: () async {
                    final result =
                        await context.push<bool>('/rabbit/$rabbitId/edit');
                    if (result == true && context.mounted) {
                      context.read<RabbitCubit>().fetch();
                    }
                  },
                ),
                if (isAtLeastRegionManager)
                  PopupMenuButton(
                    key: const Key('rabbit_info_popup_menu'),
                    itemBuilder: (_) => [
                      PopupMenuItem(
                        child: const Text('Zmień Status'),
                        onTap: () async {
                          await showModalMyBottomSheet<bool>(
                            context: context,
                            title: 'Wybierz status królika',
                            builder: (_) {
                              return ChangeStatus(
                                rabbit: rabbit,
                              );
                            },
                            onClosing: (result) {
                              if (result == true) {
                                context.read<RabbitCubit>().fetch();
                              }
                            },
                          );
                        },
                      ),
                      PopupMenuItem(
                        child: const Text('Zmień DT'),
                        onTap: () async {
                          await showModalMyBottomSheet<bool>(
                            context: context,
                            title: 'Wybierz nowych opiekunów',
                            builder: (_) {
                              return ChangeVolunteerAction(
                                rabbit: rabbit,
                              );
                            },
                            onClosing: (result) {
                              if (result == true) {
                                context.read<RabbitCubit>().fetch();
                              }
                            },
                          );
                        },
                      ),
                      PopupMenuItem(
                        child: const Text('Zmień zaprzyjaźnioną grupę'),
                        onTap: () async {
                          await showModalMyBottomSheet<bool>(
                            context: context,
                            title:
                                'Wybierz nową grupę zaprzyjaźnionych królików',
                            builder: (_) {
                              return ChangeRabbitGroupAction(
                                rabbit: rabbit,
                              );
                            },
                            onClosing: (result) {
                              if (result == true) {
                                context.read<RabbitCubit>().fetch();
                              }
                            },
                          );
                        },
                      ),
                      PopupMenuItem(
                          child: const Text('Usuń Królika'),
                          onTap: () async {
                            final result = await showDialog<bool>(
                                context: context,
                                builder: (_) {
                                  return RemoveRabbitAction(
                                    rabbitId: rabbit.id,
                                  );
                                });
                            if (context.mounted && result == true) {
                              if (context.canPop()) {
                                context.pop({
                                  'deleted': true,
                                });
                              } else {
                                context.read<RabbitCubit>().fetch();
                              }
                            }
                          })
                    ],
                  ),
              ];
            }
            return null;
          },
          persistentFooterButtonsBuilder: (context, rabbit) {
            return [
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 8.0,
                children: [
                  ActionChip(
                    key: const Key('vetVisitButton'),
                    backgroundColor:
                        Theme.of(context).colorScheme.surfaceContainerLow,
                    label: const Text(
                      'Historia Leczenia',
                      textAlign: TextAlign.center,
                    ),
                    onPressed: () =>
                        context.push('/rabbit/${rabbit.id}/notes', extra: {
                      'rabbitName': rabbit.name,
                      'isVetVisit': true,
                    }),
                  ),
                  ActionChip(
                    key: const Key('notesButton'),
                    backgroundColor:
                        Theme.of(context).colorScheme.surfaceContainerLow,
                    label: const Text(
                      'Notatki',
                      textAlign: TextAlign.center,
                    ),
                    onPressed: () =>
                        context.push('/rabbit/${rabbit.id}/notes', extra: {
                      'rabbitName': rabbit.name,
                      'isVetVisit': false,
                    }),
                  ),
                  ActionChip(
                    key: const Key('adoptionButton'),
                    backgroundColor:
                        Theme.of(context).colorScheme.surfaceContainerLow,
                    label: const Text(
                      'Adopcja',
                      textAlign: TextAlign.center,
                    ),
                    onPressed: () =>
                        context.push('/rabbitGroup/${rabbit.rabbitGroup!.id}'),
                  ),
                ],
              ),
            ];
          },
          builder: (context, rabbit) => RabbitInfoView(
                rabbit: rabbit,
                admin: isAtLeastRegionManager,
              )),
    );
  }
}
