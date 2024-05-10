import 'package:flutter/material.dart';

import 'package:spk_app_frontend/config/config.dart';

import 'package:spk_app_frontend/features/rabbits/models/models.dart';

// TODO: Implement photos library
class TopPhotoCard extends StatelessWidget {
  const TopPhotoCard({
    super.key,
    required this.rabbit,
  });

  final Rabbit rabbit;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        top: 4.0,
        bottom: 4.0,
        left: 8.0,
        right: 4.0,
      ),
      child: AspectRatio(
        aspectRatio: 1.0,
        child: Container(
          margin: const EdgeInsets.only(
            top: 2.0,
            bottom: 2.0,
            left: 8.0,
            right: 2.0,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            image: const DecorationImage(
              image: NetworkImage(
                AppConfig.photoUrl,
              ),
              fit: BoxFit.cover,
            ),
          ),
        ),
      ),
    );
  }
}
