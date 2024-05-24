import 'package:flutter/material.dart';
import 'package:spk_app_frontend/common/views/widgets/lists/card.widget.dart';

class FieldControlers {
  FieldControlers();

  final descriptionControler = TextEditingController();

  void dispose() {
    descriptionControler.dispose();
  }
}

class UpdateAdoptionInfoView extends StatefulWidget {
  const UpdateAdoptionInfoView({
    super.key,
    required this.editControlers,
  });

  final FieldControlers editControlers;

  @override
  State<UpdateAdoptionInfoView> createState() => _UpdateAdoptionInfoViewState();
}

class _UpdateAdoptionInfoViewState extends State<UpdateAdoptionInfoView> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          AppCard(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                key: const Key('descriptionField'),
                controller: widget.editControlers.descriptionControler,
                decoration: const InputDecoration(
                  labelText: 'Opis adopcyjny',
                  hintText: 'Wprawdź opis',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.multiline,
                onTapOutside: (event) => FocusScope.of(context).unfocus(),
                minLines: 3,
                maxLines: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
