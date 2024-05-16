import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:spk_app_frontend/common/extensions/extensions.dart';
import 'package:spk_app_frontend/common/views/widgets/lists/card.widget.dart';
import 'package:spk_app_frontend/features/rabbits/models/models.dart';

class AdoptionInfoView extends StatelessWidget {
  const AdoptionInfoView({
    super.key,
    required this.rabbitGroup,
  });

  final RabbitGroup rabbitGroup;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AppCard(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  rabbitGroup.rabbits.length > 1 ? 'Króliki:' : 'Królik:',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              ...ListTile.divideTiles(
                context: context,
                tiles: rabbitGroup.rabbits
                    .map(
                      (rabbit) => ListTile(
                        title: Text(rabbit.name),
                        leading: const Icon(Icons.pets),
                        onTap: () => context.push('/rabbit/${rabbit.id}'),
                      ),
                    )
                    .toList(),
              ),
            ],
          ),
        ),
        AppCard(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Opis adopcyjny',
                  style: Theme.of(context).textTheme.titleLarge,
                  textAlign: TextAlign.center,
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    rabbitGroup.adoptionDescription ??
                        'Błąd pobierania opisu adopcyjnego',
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        ),
        if (rabbitGroup.adoptionDate != null)
          AppCard(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Data adopcji:',
                    style: Theme.of(context).textTheme.titleLarge,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(width: 8),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      rabbitGroup.adoptionDate!.toDateString(),
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
