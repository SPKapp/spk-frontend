import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'package:spk_app_frontend/common/extensions/extensions.dart';
import 'package:spk_app_frontend/common/views/widgets/lists/card.widget.dart';

import 'package:spk_app_frontend/features/rabbits/models/models.dart';
import 'package:spk_app_frontend/features/rabbits/views/widgets/rabbit_info/weight_history.widget.dart';

class FullInfoCard extends StatelessWidget {
  const FullInfoCard({
    super.key,
    required this.rabbit,
    this.weightClick,
  });

  final Rabbit rabbit;
  final void Function()? weightClick;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'Pełne Informacje',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          ListTile(
            leading: const Icon(FontAwesomeIcons.weightHanging),
            title: const Text('Waga:'),
            subtitle: Text(
              (rabbit.weight != null) ? '${rabbit.weight} kg' : 'Brak danych',
            ),
            trailing: const Icon(FontAwesomeIcons.clockRotateLeft),
            onTap: weightClick ??
                () => showModalBottomSheet(
                      context: context,
                      builder: (BuildContext context) => WeightHistory(
                        rabbitId: rabbit.id.toString(),
                      ),
                      isScrollControlled: true,
                    ),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(FontAwesomeIcons.palette),
            title: const Text('Kolor:'),
            subtitle: Text(rabbit.color ?? 'Brak danych'),
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
            leading: const Icon(FontAwesomeIcons.circleXmark),
            title: const Text('Data Kastracji:'),
            subtitle: Text(
              rabbit.castrationDate?.toDateString() ?? 'Brak danych',
            ),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(FontAwesomeIcons.syringe),
            title: const Text('Data Szczepienia:'),
            subtitle: Text(
              rabbit.vaccinationDate?.toDateString() ?? 'Brak danych',
            ),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(FontAwesomeIcons.bugSlash),
            title: const Text('Data Odrobaczania:'),
            subtitle: Text(
              rabbit.dewormingDate?.toDateString() ?? 'Brak danych',
            ),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(FontAwesomeIcons.microchip),
            title: const Text('Numer Chipa:'),
            subtitle: Text(
              rabbit.chipNumber ?? 'Brak danych',
            ),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(FontAwesomeIcons.calendarDay),
            title: const Text('Data Przekazania:'),
            subtitle: Text(
              rabbit.admissionDate?.toDateString() ?? 'Brak danych',
            ),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(FontAwesomeIcons.doorOpen),
            title: const Text('Typ Przekazania:'),
            subtitle: Text(
              rabbit.admissionType.toHumanReadable(),
            ),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(FontAwesomeIcons.calendarDay),
            title: const Text('Data Zgłoszenia:'),
            subtitle: Text(
              rabbit.fillingDate?.toDateString() ?? 'Brak danych',
            ),
          ),
        ],
      ),
    );
  }
}
