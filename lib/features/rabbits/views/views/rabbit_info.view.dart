import 'package:flutter/material.dart';

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
    return SingleChildScrollView(
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
                  onPressed: () {}, // TODO: Implement this
                  text: 'Historia Leczenia',
                  right: false,
                ),
              ),
              Expanded(
                child: RabbitInfoButton(
                  onPressed: () {}, // TODO: Implement this
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
