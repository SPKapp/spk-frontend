import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'package:spk_app_frontend/common/extensions/extensions.dart';
import 'package:spk_app_frontend/common/views/widgets/lists/card.widget.dart';
import 'package:spk_app_frontend/features/rabbit-notes/models/models.dart';
import 'package:spk_app_frontend/features/rabbits/views/widgets/form_fields.dart';

class FieldControlers {
  FieldControlers({
    this.isVetVisit = false,
  });

  final descriptionControler = TextEditingController();
  final weightControler = TextEditingController();
  final dateControler = TextEditingController();
  final vaccinationControler = TextEditingController();
  final operationControler = TextEditingController();
  final chipControler = TextEditingController();
  final Set<VisitType> types = <VisitType>{};
  bool isVetVisit;

  void dispose() {
    descriptionControler.dispose();
    weightControler.dispose();
    dateControler.dispose();
    vaccinationControler.dispose();
    operationControler.dispose();
    chipControler.dispose();
  }
}

/// A StatefulWidget that represents the view for modifying or creating a RabbitNote.
class RabbitNoteModifyView extends StatefulWidget {
  const RabbitNoteModifyView({
    super.key,
    required this.editControlers,
    this.canChangeType = false,
  });

  final FieldControlers editControlers;
  final bool canChangeType;

  @override
  State<RabbitNoteModifyView> createState() => _RabbitNoteModifyViewState();
}

class _RabbitNoteModifyViewState extends State<RabbitNoteModifyView> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          if (widget.canChangeType)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ChoiceChip(
                    label: const Text('Wizyta'),
                    avatar: Icon(
                      widget.editControlers.isVetVisit == true
                          ? FontAwesomeIcons.check
                          : FontAwesomeIcons.stethoscope,
                    ),
                    showCheckmark: false,
                    selected: widget.editControlers.isVetVisit == true,
                    onSelected: (bool selected) {
                      setState(() {
                        widget.editControlers.isVetVisit = true;
                      });
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ChoiceChip(
                    label: const Text('Notatka'),
                    avatar: Icon(
                      widget.editControlers.isVetVisit == false
                          ? FontAwesomeIcons.check
                          : FontAwesomeIcons.noteSticky,
                    ),
                    showCheckmark: false,
                    selected: widget.editControlers.isVetVisit == false,
                    onSelected: (bool selected) {
                      setState(() {
                        widget.editControlers.isVetVisit = false;
                      });
                    },
                  ),
                ),
              ],
            ),
          if (!widget.editControlers.isVetVisit)
            AppCard(
              key: const Key('noteCard'),
              child: Column(
                children: [
                  _buildDescriptionInput(),
                  _buildWeightInput(),
                ],
              ),
            ),
          if (widget.editControlers.isVetVisit)
            AppCard(
              key: const Key('vetVisitCard'),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    Text(
                      'Typ Wizyty',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8.0),
                    Wrap(
                      spacing: 5.0,
                      alignment: WrapAlignment.center,
                      children: VisitType.values.map((type) {
                        return FilterChip(
                          key: Key('${type.toString()}Chip'),
                          label: Text(type.displayName),
                          selected: widget.editControlers.types.contains(type),
                          onSelected: (bool selected) {
                            setState(() {
                              if (selected) {
                                widget.editControlers.types.add(type);
                                if (type == VisitType.control) {
                                  widget.editControlers.types
                                      .remove(VisitType.treatment);
                                } else if (type == VisitType.treatment) {
                                  widget.editControlers.types
                                      .remove(VisitType.control);
                                }
                              } else {
                                widget.editControlers.types.remove(type);
                              }
                            });
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 8.0),
                    DateField(
                      controller: widget.editControlers.dateControler,
                      labelText: 'Data wizyty',
                      hintText: 'Wprawdź datę wizyty',
                      icon: FontAwesomeIcons.calendarDay,
                      onTap: (DateTime date) {
                        setState(() {
                          widget.editControlers.dateControler.text =
                              date.toDateString();
                        });
                      },
                      validator: (value) =>
                          value!.isEmpty ? 'Pole nie może być puste' : null,
                    ),
                    _buildWeightInput(),
                    _buildDescriptionInput(),
                    if (widget.editControlers.types
                        .contains(VisitType.vaccination))
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TextFormField(
                          key: const Key('vaccinationInput'),
                          controller:
                              widget.editControlers.vaccinationControler,
                          decoration: const InputDecoration(
                            labelText: 'Rodzaj szczepionki',
                            hintText: 'Wprawdź szczepionkę',
                            border: OutlineInputBorder(),
                          ),
                          onTapOutside: (event) =>
                              FocusScope.of(context).unfocus(),
                          validator: (value) =>
                              value!.isEmpty ? 'Pole nie może być puste' : null,
                        ),
                      ),
                    if (widget.editControlers.types
                        .contains(VisitType.operation))
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TextFormField(
                          key: const Key('operationInput'),
                          controller: widget.editControlers.operationControler,
                          decoration: const InputDecoration(
                            labelText: 'Rodzaj operacji',
                            hintText: 'Wprawdź operację',
                            border: OutlineInputBorder(),
                          ),
                          onTapOutside: (event) =>
                              FocusScope.of(context).unfocus(),
                          validator: (value) =>
                              value!.isEmpty ? 'Pole nie może być puste' : null,
                        ),
                      ),
                    if (widget.editControlers.types.contains(VisitType.chip))
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TextFormField(
                          key: const Key('chipInput'),
                          controller: widget.editControlers.chipControler,
                          decoration: const InputDecoration(
                            labelText: 'Numer chipa',
                            hintText: 'Wprawdź numer chipa',
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.number,
                          onTapOutside: (event) =>
                              FocusScope.of(context).unfocus(),
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          validator: (value) =>
                              value!.isEmpty ? 'Pole nie może być puste' : null,
                        ),
                      ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDescriptionInput() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextFormField(
        key: const Key('descriptionField'),
        controller: widget.editControlers.descriptionControler,
        decoration: const InputDecoration(
          labelText: 'Opis',
          hintText: 'Wprawdź opis',
          border: OutlineInputBorder(),
        ),
        keyboardType: TextInputType.multiline,
        onTapOutside: (event) => FocusScope.of(context).unfocus(),
        minLines: 3,
        maxLines: 12,
        validator: (value) => value!.isEmpty ? 'Pole nie może być puste' : null,
      ),
    );
  }

  Widget _buildWeightInput() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextFormField(
        controller: widget.editControlers.weightControler,
        textAlign: TextAlign.center,
        decoration: const InputDecoration(
          labelText: 'Waga',
          hintText: 'Wprawdź wagę',
          border: OutlineInputBorder(),
          prefixIcon: Icon(FontAwesomeIcons.weightScale),
          suffixText: 'kg',
        ),
        keyboardType: TextInputType.number,
        onTapOutside: (event) => FocusScope.of(context).unfocus(),
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
        ],
      ),
    );
  }
}
