import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';

import 'package:spk_app_frontend/common/extensions/extensions.dart';
import 'package:spk_app_frontend/common/views/widgets/lists/card.widget.dart';
import 'package:spk_app_frontend/features/rabbit-notes/models/models.dart';

/// A widget representing a single item in the Rabbit Notes list.
///
/// This widget displays a single item in the Rabbit Notes list. It displays the type of the note, the description, and the date of creation.
/// If the note is a vet visit, it displays the visit type and the date of the visit.
///
/// if the [rabbitName] is provided, it will be passed to the rabbitNote page when the item is clicked.
class RabbitNoteListItem extends StatefulWidget {
  const RabbitNoteListItem({
    super.key,
    required this.rabbitNote,
    this.rabbitName,
  });

  final RabbitNote rabbitNote;
  final String? rabbitName;

  @override
  State<RabbitNoteListItem> createState() => _RabbitNoteListItemState();
}

class _RabbitNoteListItemState extends State<RabbitNoteListItem> {
  bool isDeleted = false;

  @override
  Widget build(BuildContext context) {
    late Widget icon;
    late String title;
    late String subtitle;
    late String date;
    if (widget.rabbitNote.vetVisit != null) {
      icon = const Icon(FontAwesomeIcons.stethoscope);
      title = 'Wizyta Weterynaryjna';
      subtitle = widget.rabbitNote.vetVisit!.visitInfo
          .map((e) => e.visitType.displayName)
          .join(', ');
      date = widget.rabbitNote.vetVisit!.date != null
          ? '${widget.rabbitNote.vetVisit!.date!.toDateString()}\n${widget.rabbitNote.vetVisit!.date!.toTimeString()}'
          : 'Nieznana\ndata wizyty';
    } else {
      icon = const Icon(FontAwesomeIcons.noteSticky);
      title = 'Notatka';
      subtitle = widget.rabbitNote.description ?? '';

      date = widget.rabbitNote.createdAt != null
          ? '${widget.rabbitNote.createdAt!.toDateString()}\n${widget.rabbitNote.createdAt!.toTimeString()}'
          : 'Nieznana\ndata utworzenia';
    }

    return Visibility(
      visible: !isDeleted,
      child: AppCard(
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
          onTap: () async {
            final result = await context
                .push<dynamic>('/note/${widget.rabbitNote.id}', extra: {
              'rabbitName': widget.rabbitName,
            });

            if (context.mounted &&
                result != null &&
                result['deleted'] == true) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Notatka została usunięta'),
                ),
              );
              setState(() {
                isDeleted = true;
              });
            }
          },
        ),
      ),
    );
  }
}
