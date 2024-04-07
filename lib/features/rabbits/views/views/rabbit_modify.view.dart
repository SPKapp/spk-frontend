import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'package:spk_app_frontend/common/extensions/extensions.dart';

import 'package:spk_app_frontend/features/rabbits/models/models.dart';
import 'package:spk_app_frontend/features/rabbits/views/widgets/form_fields.dart';

import 'package:spk_app_frontend/features/regions/models/models.dart';

class FieldControlers {
  FieldControlers();

  final nameControler = TextEditingController();
  final birthDateControler = TextEditingController();
  final colorControler = TextEditingController();
  final breedControler = TextEditingController();
  final admissionDateControler = TextEditingController();
  final filingDateControler = TextEditingController();
  Gender selectedGender = Gender.unknown;
  AdmissionType selectedAdmissionType = AdmissionType.found;
  bool confirmedBirthDate = false;
  Region? selectedRegion;

  void dispose() {
    nameControler.dispose();
    birthDateControler.dispose();
    colorControler.dispose();
    breedControler.dispose();
    admissionDateControler.dispose();
    filingDateControler.dispose();
  }
}

/// A StatefulWidget that represents the view for modifying or creating a rabbit.
class RabbitModifyView extends StatefulWidget {
  const RabbitModifyView({
    super.key,
    required this.editControlers,
    this.regions,
  });

  final FieldControlers editControlers;
  final List<Region>? regions;

  @override
  State<RabbitModifyView> createState() => _RabbitModifyViewState();
}

class _RabbitModifyViewState extends State<RabbitModifyView> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Card(
          margin: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                AppTextField(
                    key: const Key('nameTextField'),
                    controller: widget.editControlers.nameControler,
                    labelText: 'Imię',
                    hintText: 'Podaj imię królika',
                    icon: FontAwesomeIcons.penToSquare,
                    validator: (value) =>
                        value!.isEmpty ? 'Pole nie może być puste' : null),
                GenderDropdown(
                  onSelected: (Gender? gender) {
                    if (gender != null) {
                      setState(() {
                        widget.editControlers.selectedGender = gender;
                      });
                    }
                  },
                  initialSelection: widget.editControlers.selectedGender,
                ),
                BirthDateField(
                  controller: widget.editControlers.birthDateControler,
                  onTap: (DateTime date) {
                    setState(() {
                      widget.editControlers.birthDateControler.text =
                          date.toDateString();
                    });
                  },
                  onConfirmedBirthDate: () {
                    setState(() {
                      widget.editControlers.confirmedBirthDate =
                          !widget.editControlers.confirmedBirthDate;
                    });
                  },
                  confirmedBirthDate: widget.editControlers.confirmedBirthDate,
                ),
                AppTextField(
                  key: const Key('colorTextField'),
                  controller: widget.editControlers.colorControler,
                  labelText: 'Kolor',
                  hintText: 'Podaj kolor królika',
                  icon: FontAwesomeIcons.palette,
                ),
                AppTextField(
                  key: const Key('breedTextField'),
                  controller: widget.editControlers.breedControler,
                  labelText: 'Rasa',
                  hintText: 'Podaj rasę królika',
                  icon: FontAwesomeIcons.dna,
                ),
                DateField(
                  key: const Key('admissionDateField'),
                  controller: widget.editControlers.admissionDateControler,
                  labelText: 'Data Przekazania',
                  hintText: 'Podaj datę przekazania do Fundacji',
                  icon: FontAwesomeIcons.calendarDay,
                  onTap: (DateTime date) async {
                    setState(() {
                      widget.editControlers.admissionDateControler.text =
                          date.toDateString();
                    });
                  },
                ),
                AdmissionTypeDropdown(
                  onSelected: (AdmissionType? admissionType) {
                    if (admissionType != null) {
                      setState(() {
                        widget.editControlers.selectedAdmissionType =
                            admissionType;
                      });
                    }
                  },
                  initialSelection: AdmissionType.found,
                ),
                DateField(
                  key: const Key('filingDateField'),
                  controller: widget.editControlers.filingDateControler,
                  labelText: 'Data Zgłoszenia',
                  hintText: 'Podaj datę zgłoszenia do Fundacji',
                  icon: FontAwesomeIcons.calendarDay,
                  daysBefore: 3650,
                  daysAfter: 0,
                  onTap: (DateTime date) async {
                    setState(() {
                      widget.editControlers.filingDateControler.text =
                          date.toDateString();
                    });
                  },
                ),
                if (widget.regions != null)
                  RegionDropdown(
                    key: const Key('regionDropdown'),
                    regions: widget.regions!,
                    onSelected: (Region? region) {
                      if (region != null) {
                        setState(() {
                          widget.editControlers.selectedRegion = region;
                        });
                      }
                    },
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
