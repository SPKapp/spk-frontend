import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:spk_app_frontend/common/views/widgets/lists/card.widget.dart';

import 'package:spk_app_frontend/features/users/models/models.dart';

/// A widget that represents a volunteer card.
///
/// This widget is used to display information about a volunteer who takes care of a given rabbit.
/// This widget is used in the [RabbitInfoView] widget.
class VolunteerCard extends StatelessWidget {
  const VolunteerCard({
    super.key,
    required this.volunteers,
  });

  final Iterable<User> volunteers;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: volunteers.isEmpty
          ? Padding(
              padding: const EdgeInsets.all(8.0),
              child: Center(
                child: Text(
                  'Brak przypisanego Opiekuna',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
            )
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    volunteers.length > 1 ? 'Opiekunowie' : 'Opiekun',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                ...ListTile.divideTiles(
                  context: context,
                  tiles: volunteers
                      .map(
                        (volunteer) => ListTile(
                          title: Text(volunteer.fullName),
                          leading: const Icon(Icons.person),
                          onTap: () => context.push('/user/${volunteer.id}'),
                        ),
                      )
                      .toList(),
                ),
              ],
            ),
    );
  }
}
