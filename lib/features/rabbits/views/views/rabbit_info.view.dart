import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'package:spk_app_frontend/common/extensions/extensions.dart';
import 'package:spk_app_frontend/config/config.local.dart';

import 'package:spk_app_frontend/features/rabbits/models/models.dart';
import 'package:spk_app_frontend/features/rabbits/views/widgets/list_items.dart';

// TODO: Add tests for this widget
// TODO: Refactor this widget
class RabbitInfoView extends StatelessWidget {
  const RabbitInfoView({super.key, required this.rabbit});

  final Rabbit rabbit;

  @override
  Widget build(BuildContext context) {
    final infoTheme = Theme.of(context).textTheme.titleMedium;

    return SingleChildScrollView(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: LayoutBuilder(
              builder: (context, constraints) => SizedBox(
                height: constraints.maxWidth * 0.5,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Expanded(
                      child: _TopPhotoCard(link: LocalConfig.photoUrl),
                    ),
                    Expanded(
                      child: _TopInfoCard(rabbit: rabbit, infoTheme: infoTheme),
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (rabbit.rabbitGroup != null &&
              rabbit.rabbitGroup!.rabbits.length > 1)
            _RabbitGroupCard(infoTheme: infoTheme, rabbit: rabbit),
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
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: SizedBox(
        width: double.infinity,
        child: Card(
          margin: const EdgeInsets.symmetric(horizontal: 8.0),
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
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: SizedBox(
        width: double.infinity,
        child: Card(
          margin: const EdgeInsets.symmetric(horizontal: 8.0),
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
                      subtitle: Text((rabbit.color != null)
                          ? rabbit.color!
                          : 'Brak danych'),
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
        ),
      ),
    );
  }
}

class _RabbitGroupCard extends StatelessWidget {
  const _RabbitGroupCard({
    required this.rabbit,
    this.infoTheme,
  });

  final Rabbit rabbit;
  final TextStyle? infoTheme;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: SizedBox(
        width: double.infinity,
        child: Card(
          margin: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  'Zaprzyjaźnione Króliki:',
                  style: infoTheme,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Wrap(
                  spacing: 8.0,
                  children: rabbit.rabbitGroup!.rabbits
                      .where((r) => r.id != rabbit.id)
                      .map((r) => RabbitListItem(id: r.id, name: r.name))
                      .toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TopPhotoCard extends StatelessWidget {
  const _TopPhotoCard({required this.link});

  final String? link;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) => Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Image.network(
            link ?? LocalConfig.photoUrl,
            fit: BoxFit.fitHeight,
            height: constraints.maxWidth,
          ),
        ),
      ),
    );
  }
}

class _TopInfoCard extends StatelessWidget {
  const _TopInfoCard({
    required this.rabbit,
    required this.infoTheme,
  });

  final Rabbit rabbit;
  final TextStyle? infoTheme;

  @override
  Widget build(BuildContext context) {
    int age = 0;
    int ageInMonths = 0;

    if (rabbit.birthDate != null) {
      age = DateTime.now().differenceInYears(rabbit.birthDate!);
      if (age <= 1) {
        ageInMonths = DateTime.now().differenceInMonths(rabbit.birthDate!);
        if (ageInMonths >= 12) {
          ageInMonths = ageInMonths - 12;
        }
      }
    }

    return Card(
      margin: const EdgeInsets.all(8.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Text(
            switch (rabbit.gender) {
              Gender.male => 'Samiec',
              Gender.female => 'Samiczka',
              Gender.unknown => 'Płeć Nieznana',
            },
            style: infoTheme,
          ),
          Text(
            switch ((age, ageInMonths)) {
              (0, 0) => 'Wiek Nieznany',
              (0, 1) => '1 miesiąc',
              (0, >= 2 && <= 4) => '$ageInMonths miesiące',
              (0, _) => '$ageInMonths miesięcy',
              (1, 0) => 'Rok',
              (1, 1) => 'Rok 1 miesiąc',
              (1, >= 2 && <= 4) => 'Rok $ageInMonths miesiące',
              (1, _) => 'Rok $ageInMonths miesięcy',
              (>= 2 && <= 4, _) => '$age lata',
              _ => '$age lat',
            },
            style: infoTheme,
          ),
          Text(
            rabbit.breed ?? 'Rasa Nieznana',
            style: infoTheme,
          ),
          Text(
            'Status', // TODO: Add status to Rabbit model
            style: infoTheme,
          ),
        ],
      ),
    );
  }
}
