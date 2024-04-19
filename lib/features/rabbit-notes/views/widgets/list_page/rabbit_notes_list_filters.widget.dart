import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';

import 'package:spk_app_frontend/common/extensions/extensions.dart';
import 'package:spk_app_frontend/common/views/widgets/filter_chips.dart';
import 'package:spk_app_frontend/features/rabbit-notes/bloc/rabbit_notes_list.bloc.dart';
import 'package:spk_app_frontend/features/rabbit-notes/models/dto.dart';
import 'package:spk_app_frontend/features/rabbit-notes/models/models.dart';

/// A widget that represents the filters for the Rabbit Notes list.
/// This widget is used to filter the Rabbit Notes list based on certain criteria.
class RabbitNotesListFilters extends StatefulWidget {
  const RabbitNotesListFilters({
    super.key,
    required this.args,
  });

  final FindRabbitNotesArgs args;

  @override
  State<RabbitNotesListFilters> createState() => _RabbitNotesListFiltersState();
}

class _RabbitNotesListFiltersState extends State<RabbitNotesListFilters> {
  late FindRabbitNotesArgs args = widget.args;
  late Set<VisitType> filters =
      widget.args.vetVisit?.visitTypes?.toSet() ?? <VisitType>{};

  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      widthFactor: 1.0,
      heightFactor: 0.7,
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  'Filtruj notatki',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ChoiceChip(
                      label: const Text('Wszystkie'),
                      avatar: Icon(
                        args.isVetVisit == null
                            ? FontAwesomeIcons.check
                            : FontAwesomeIcons.solidNoteSticky,
                      ),
                      showCheckmark: false,
                      selected: args.isVetVisit == null,
                      onSelected: (bool selected) {
                        setState(() {
                          args = args.copyWith(isVetVisit: () => null);
                        });
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ChoiceChip(
                      label: const Text('Wizyty'),
                      avatar: Icon(
                        args.isVetVisit == true
                            ? FontAwesomeIcons.check
                            : FontAwesomeIcons.stethoscope,
                      ),
                      showCheckmark: false,
                      selected: args.isVetVisit == true,
                      onSelected: (bool selected) {
                        setState(() {
                          args = args.copyWith(isVetVisit: () => true);
                        });
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ChoiceChip(
                      label: const Text('Notatki'),
                      avatar: Icon(
                        args.isVetVisit == false
                            ? FontAwesomeIcons.check
                            : FontAwesomeIcons.noteSticky,
                      ),
                      showCheckmark: false,
                      selected: args.isVetVisit == false,
                      onSelected: (bool selected) {
                        setState(() {
                          args = args.copyWith(isVetVisit: () => false);
                        });
                      },
                    ),
                  ),
                ],
              ),
              if (args.isVetVisit == true) ...[
                const Padding(
                  key: Key('visitDate'),
                  padding: EdgeInsets.all(8.0),
                  child: Text('Data Wizyty'),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    DateChip(
                      date: args.vetVisit?.dateFrom,
                      icon: FontAwesomeIcons.calendarPlus,
                      emptyText: 'Podaj datę od',
                      filledText:
                          'Od: ${args.vetVisit?.dateFrom?.toDateString()}',
                      onDateChanged: (date) {
                        setState(() {
                          args = args.copyWith(
                            vetVisit: () =>
                                args.vetVisit?.copyWith(dateFrom: () => date) ??
                                VetVisitArgs(dateFrom: date),
                          );
                        });
                      },
                    ),
                    DateChip(
                      date: args.vetVisit?.dateTo,
                      icon: FontAwesomeIcons.calendarMinus,
                      emptyText: 'Podaj datę do',
                      filledText:
                          'Do: ${args.vetVisit?.dateTo?.toDateString()}',
                      onDateChanged: (date) {
                        setState(() {
                          args = args.copyWith(
                            vetVisit: () =>
                                args.vetVisit?.copyWith(dateTo: () => date) ??
                                VetVisitArgs(dateTo: date),
                          );
                        });
                      },
                    ),
                  ],
                ),
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text('Typ Wizyty'),
                ),
                Wrap(
                  spacing: 5.0,
                  alignment: WrapAlignment.center,
                  children: VisitType.values.map((type) {
                    return FilterChip(
                      label: Text(type.displayName),
                      selected: filters.contains(type),
                      onSelected: (bool selected) {
                        setState(() {
                          if (selected) {
                            filters.add(type);
                          } else {
                            filters.remove(type);
                          }
                        });
                      },
                    );
                  }).toList(),
                ),
              ] else ...[
                const Padding(
                  key: Key('noteDate'),
                  padding: EdgeInsets.all(8.0),
                  child: Text('Data Utworzenia'),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    DateChip(
                      date: args.createdAtFrom,
                      icon: FontAwesomeIcons.calendarPlus,
                      emptyText: 'Podaj datę od',
                      filledText: 'Od: ${args.createdAtFrom?.toDateString()}',
                      onDateChanged: (date) {
                        setState(() {
                          args = args.copyWith(
                            createdAtFrom: () => date,
                          );
                        });
                      },
                    ),
                    DateChip(
                      date: args.createdAtTo,
                      icon: FontAwesomeIcons.calendarMinus,
                      emptyText: 'Podaj datę do',
                      filledText: 'Do: ${args.createdAtTo?.toDateString()}',
                      onDateChanged: (date) {
                        setState(() {
                          args = args.copyWith(
                            createdAtTo: () => date,
                          );
                        });
                      },
                    ),
                  ],
                ),
              ],
              const SizedBox(
                height: 6,
              ),
              FilledButton.tonal(
                onPressed: () {
                  args = args.isVetVisit == true
                      ? args.copyWith(
                          createdAtFrom: () => null,
                          createdAtTo: () => null,
                          vetVisit: () =>
                              args.vetVisit?.copyWith(
                                visitTypes: () =>
                                    filters.isEmpty ? filters.toList() : null,
                              ) ??
                              VetVisitArgs(
                                visitTypes: filters.toList(),
                              ),
                        )
                      : args.copyWith(
                          vetVisit: () => null,
                        );
                  context
                      .read<RabbitNotesListBloc>()
                      .add(RefreshRabbitNotes(args));
                  context.pop();
                },
                child: const Text('Filtruj'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
