import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'package:spk_app_frontend/common/extensions/extensions.dart';
import 'package:spk_app_frontend/common/views/widgets/lists/card.widget.dart';

import 'package:spk_app_frontend/features/rabbits/models/models.dart';
import 'package:spk_app_frontend/features/rabbits/views/widgets/rabbit_info.dart';

// TODO: Add tests for this widget
// TODO: Refactor this widget
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
    final infoTheme = Theme.of(context).textTheme.titleMedium;

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
          _FullInfoCard(infoTheme: infoTheme, rabbit: rabbit),
          _VetVisitsInfoCard(infoTheme: infoTheme, rabbit: rabbit),
        ],
      ),
    );
  }
}

class _VetVisitsInfoCard extends StatelessWidget {
  const _VetVisitsInfoCard({
    required this.rabbit,
    this.infoTheme,
  });

  final Rabbit rabbit;
  final TextStyle? infoTheme;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: AppCard(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'Wizyty Weterynaryjne:',
                style: infoTheme,
              ),
            ),
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Column(
                children: [],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FullInfoCard extends StatelessWidget {
  const _FullInfoCard({
    required this.rabbit,
    this.infoTheme,
  });

  final Rabbit rabbit;
  final TextStyle? infoTheme;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'Pełne Informacje:',
              style: infoTheme,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(FontAwesomeIcons.weightHanging),
                  title: const Text('Waga:'),
                  subtitle: Text(
                    (rabbit.weight != null)
                        ? '${rabbit.weight} kg'
                        : 'Brak danych',
                  ),
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(FontAwesomeIcons.calendarDay),
                  title: const Text('Data Urodzenia:'),
                  subtitle: Text(
                    (rabbit.birthDate != null)
                        ? (rabbit.confirmedBirthDate)
                            ? rabbit.birthDate!.toDateString()
                            : 'Około ${rabbit.birthDate!.toDateString()}'
                        : 'Brak danych',
                  ),
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(FontAwesomeIcons.palette),
                  title: const Text('Kolor:'),
                  subtitle: Text(
                      (rabbit.color != null) ? rabbit.color! : 'Brak danych'),
                ),
                const Divider(),
                const ListTile(
                  leading: Icon(FontAwesomeIcons.info),
                  title: Text('Tutaj będzie reszta parametrów:'),
                  subtitle: Text('I ich wartości'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
