import 'package:flutter/material.dart';

import 'package:spk_app_frontend/common/extensions/extensions.dart';

import 'package:spk_app_frontend/features/rabbits/models/models.dart';

class TopInfoCard extends StatelessWidget {
  const TopInfoCard({
    super.key,
    required this.rabbit,
  });

  final Rabbit rabbit;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        top: 4.0,
        bottom: 4.0,
        left: 4.0,
        right: 8.0,
      ),
      child: AspectRatio(
        aspectRatio: 1.0,
        child: Card(
          margin: const EdgeInsets.only(
            top: 2.0,
            bottom: 2.0,
            left: 2.0,
            right: 8.0,
          ),
          child: Padding(
            padding: const EdgeInsets.only(
              top: 2.0,
              bottom: 2.0,
              left: 2.0,
              right: 8.0,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _genderText(context),
                _ageText(context),
                Text(
                  rabbit.breed ?? 'Rasa Nieznana',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                _statusText(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _genderText(BuildContext context) {
    return Text(
      switch (rabbit.gender) {
        Gender.male => 'Samiec',
        Gender.female => 'Samiczka',
        Gender.unknown => 'Płeć Nieznana',
      },
      style: Theme.of(context).textTheme.titleMedium,
    );
  }

  Widget _ageText(BuildContext context) {
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

    return Text(
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
      style: Theme.of(context).textTheme.titleMedium,
    );
  }

  Widget _statusText(BuildContext context) {
    return Text(
      rabbit.status?.displayName ?? 'Nieznany status',
      style: Theme.of(context).textTheme.titleMedium,
    );
  }
}
