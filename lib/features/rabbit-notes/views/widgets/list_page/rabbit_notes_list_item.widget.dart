import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';

import 'package:spk_app_frontend/common/extensions/extensions.dart';
import 'package:spk_app_frontend/common/views/widgets/lists/card.widget.dart';
import 'package:spk_app_frontend/features/rabbit-notes/models/models.dart';

class RabbitNoteListItem extends StatelessWidget {
  const RabbitNoteListItem({
    super.key,
    required this.rabbitNote,
    this.rabbitName,
  });

  final RabbitNote rabbitNote;
  final String? rabbitName;

  @override
  Widget build(BuildContext context) {
    late Widget icon;
    late String title;
    late String subtitle;
    late String date;
    if (rabbitNote.vetVisit != null) {
      icon = const Icon(FontAwesomeIcons.stethoscope);
      title = 'Wizyta Weterynaryjna';
      subtitle = rabbitNote.vetVisit!.visitInfo
          .map((e) => e.visitType.displayName)
          .join(', ');
      date = rabbitNote.vetVisit!.date != null
          ? '${rabbitNote.vetVisit!.date!.toDateString()}\n${rabbitNote.vetVisit!.date!.toTimeString()}'
          : 'Nieznana\ndata wizyty';
    } else {
      icon = const Icon(FontAwesomeIcons.noteSticky);
      title = 'Notatka';
      subtitle = rabbitNote.description ?? '';

      date = rabbitNote.createdAt != null
          ? '${rabbitNote.createdAt!.toDateString()}\n${rabbitNote.createdAt!.toTimeString()}'
          : 'Nieznana\ndata utworzenia';
    }

    return AppCard(
      child: ListTile(
        leading: icon,
        title: Text(title),
        subtitle: Text(
          subtitle,
          maxLines: 3,
        ),
        trailing: Text(
          date,
          textAlign: TextAlign.right,
        ),
        onTap: () {
          context.push('/note/${rabbitNote.id}', extra: {
            'rabbitName': rabbitName,
          });
        },
      ),
    );
  }
}
