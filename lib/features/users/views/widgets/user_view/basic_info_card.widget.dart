import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'package:spk_app_frontend/common/views/widgets/lists/card.widget.dart';
import 'package:spk_app_frontend/features/users/models/models.dart';

class BasicInfoCard extends StatelessWidget {
  const BasicInfoCard({super.key, required this.user});

  final User user;

  @override
  Widget build(BuildContext context) {
    return AppCard(
        child: Column(
      children: [
        ListTile(
          title: Text(user.email != null ? 'Email' : 'Brak adresu email'),
          subtitle: user.email != null ? Text(user.email!) : null,
          leading: const Icon(Icons.email),
        ),
        ListTile(
          title: Text(user.phone != null ? 'Telefon' : 'Brak numeru telefonu'),
          subtitle: user.phone != null ? Text(user.phone!) : null,
          leading: const Icon(Icons.phone),
        ),
        ListTile(
          title: Text(user.region != null ? 'Region' : 'Brak regionu'),
          subtitle:
              user.region != null ? Text(user.region?.name ?? '???') : null,
          leading: const Icon(FontAwesomeIcons.locationDot),
        ),
      ],
    ));
  }
}
