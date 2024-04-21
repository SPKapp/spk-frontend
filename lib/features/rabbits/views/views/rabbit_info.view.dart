import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:spk_app_frontend/common/views/views.dart';
import 'package:spk_app_frontend/features/rabbits/bloc/rabbit.cubit.dart';

import 'package:spk_app_frontend/features/rabbits/models/models.dart';
import 'package:spk_app_frontend/features/rabbits/views/widgets/rabbit_info.dart';

/// A view that displays information about a rabbit.
class RabbitInfoView extends StatelessWidget {
  const RabbitInfoView({
    super.key,
    required this.rabbit,
    this.admin = true,
  });

  final Rabbit rabbit;
  final bool admin;

  @override
  Widget build(BuildContext context) {
    return ItemView(
      onRefresh: () async {
        // skip initial state
        Future cubit = context.read<RabbitCubit>().stream.skip(1).first;
        context.read<RabbitCubit>().refreshRabbit();
        return cubit;
      },
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TopPhotoCard(
                  rabbit: rabbit,
                ),
              ),
              Expanded(
                child: TopInfoCard(
                  rabbit: rabbit,
                ),
              ),
            ],
          ),
          if (rabbit.rabbitGroup!.rabbits.length > 1)
            RabbitGroupCard(
              rabbits:
                  rabbit.rabbitGroup!.rabbits.where((r) => r.id != rabbit.id),
            ),
          if (admin)
            VolunteerCard(
              volunteers: rabbit.rabbitGroup!.team?.users ?? [],
            ),
          Row(
            children: [
              Expanded(
                child: RabbitInfoButton(
                  key: const Key('vet-visit-button'),
                  onPressed: () =>
                      context.push('/rabbit/${rabbit.id}/notes', extra: {
                    'rabbitName': rabbit.name,
                    'isVetVisit': true,
                  }),
                  text: 'Historia Leczenia',
                  right: false,
                ),
              ),
              Expanded(
                child: RabbitInfoButton(
                  key: const Key('notes-button'),
                  onPressed: () =>
                      context.push('/rabbit/${rabbit.id}/notes', extra: {
                    'rabbitName': rabbit.name,
                    'isVetVisit': false,
                  }),
                  text: 'Notatki',
                  right: true,
                ),
              ),
            ],
          ),
          FullInfoCard(rabbit: rabbit),
        ],
      ),
    );
  }
}
