import 'package:flutter/material.dart';

import 'package:spk_app_frontend/config/config.local.dart';

import 'package:spk_app_frontend/features/rabbits/models/models.dart';
import 'package:spk_app_frontend/features/rabbits/views/widgets/rabbit_list_item.widget.dart';

class RabbitInfo extends StatelessWidget {
  const RabbitInfo({super.key, required this.rabbit});

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
                    Expanded(
                      child: LayoutBuilder(
                        builder: (context, constraints) => Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Container(
                            clipBehavior: Clip.antiAlias,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Image.network(
                              LocalConfig.photoUrl,
                              fit: BoxFit.fitHeight,
                              height: constraints.maxWidth,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Card(
                        margin: const EdgeInsets.all(8.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Text(
                              'Samiczka',
                              style: infoTheme,
                            ),
                            Text(
                              '${rabbit.id} Lat 8 Miesięcy',
                              style: infoTheme,
                            ),
                            Text(
                              'Baranek',
                              style: infoTheme,
                            ),
                            Text(
                              'Przed Kastracją',
                              style: infoTheme,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (rabbit.rabbitGroup != null &&
              rabbit.rabbitGroup!.rabbits.length > 1)
            Padding(
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
                              .map(
                                  (r) => RabbitListItem(id: r.id, name: r.name))
                              .toList(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          Padding(
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
                    const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Column(
                        children: [
                          ListTile(
                            title: Text('Waga:'),
                            subtitle: Text('2 kg'),
                          ),
                          ListTile(
                            title: Text('Rasa:'),
                            subtitle: Text('Mieszaniec'),
                          ),
                          ListTile(
                            title: Text('Kolor:'),
                            subtitle: Text('Biały'),
                          ),
                          ListTile(
                            title: Text('Znaki Szczególne:'),
                            subtitle: Text('Brak'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
