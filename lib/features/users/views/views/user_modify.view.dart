import 'package:flutter/material.dart';
import 'package:email_validator/email_validator.dart';

import 'package:spk_app_frontend/common/views/widgets/form_fields.dart';
import 'package:spk_app_frontend/features/regions/views/views.dart';
import 'package:spk_app_frontend/features/regions/models/models.dart';

class FieldControlers {
  FieldControlers();

  final firstnameControler = TextEditingController();
  final lastnameControler = TextEditingController();
  final emailControler = TextEditingController();
  final phoneControler = TextEditingController();
  Region? selectedRegion;

  void dispose() {
    firstnameControler.dispose();
    lastnameControler.dispose();
    emailControler.dispose();
    phoneControler.dispose();
  }
}

/// A StatefulWidget that represents the view for modifying or creating a user.
///
/// Region dropdown is only displayed when the [regions] are provided.
class UserModifyView extends StatefulWidget {
  const UserModifyView({
    super.key,
    required this.editControlers,
    this.regions,
  });

  final FieldControlers editControlers;
  final List<Region>? regions;

  @override
  State<UserModifyView> createState() => _UserModifyViewState();
}

class _UserModifyViewState extends State<UserModifyView> {
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
                  key: const Key('firstnameTextField'),
                  controller: widget.editControlers.firstnameControler,
                  labelText: 'Imię',
                  hintText: 'Wpisz imię',
                  icon: Icons.person,
                  validator: lengthValidator,
                ),
                AppTextField(
                  key: const Key('lastnameTextField'),
                  controller: widget.editControlers.lastnameControler,
                  labelText: 'Nazwisko',
                  hintText: 'Wpisz nazwisko',
                  icon: Icons.person,
                  validator: lengthValidator,
                ),
                AppTextField(
                  key: const Key('emailTextField'),
                  controller: widget.editControlers.emailControler,
                  labelText: 'Email',
                  hintText: 'Wpisz email',
                  icon: Icons.email,
                  keyboardType: TextInputType.emailAddress,
                  validator: emailValidator,
                ),
                AppTextField(
                  key: const Key('phoneTextField'),
                  controller: widget.editControlers.phoneControler,
                  labelText: 'Telefon',
                  hintText: 'Wpisz telefon',
                  icon: Icons.phone,
                  keyboardType: TextInputType.phone,
                  validator: phoneValidator,
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

  String? lengthValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'Pole nie może być puste.';
    }
    return null;
  }

  String? emailValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'Pole nie może być puste.';
    }
    if (!EmailValidator.validate(value)) {
      return 'Niepoprawny email';
    }
    return null;
  }

  String? phoneValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'Pole nie może być puste.';
    }
    if (!RegExp(r'^(\+48){0,1}\d{9}$').hasMatch(value)) {
      return 'Niepoprawny numer telefonu.';
    }
    return null;
  }
}
