import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:spk_app_frontend/common/storage/storage.dart';
import 'package:spk_app_frontend/features/rabbit_photos/bloc/rabbit_photos.bloc.dart';
import 'package:spk_app_frontend/features/rabbits/models/models.dart';

class TopPhotoCard extends StatelessWidget {
  const TopPhotoCard({
    super.key,
    required this.rabbit,
  });

  final Rabbit rabbit;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => RabbitPhotosBloc(
        rabbitId: rabbit.id,
        storageAuthRepository: context.read<IStorageAuthRepository>(),
      )..add(const RabbitPhotosGetDefaultPhoto()),
      child: Padding(
        padding: const EdgeInsets.only(
          top: 4.0,
          bottom: 4.0,
          left: 8.0,
          right: 4.0,
        ),
        child: BlocBuilder<RabbitPhotosBloc, RabbitPhotosState>(
          builder: (context, state) {
            late Widget child;

            if (state is RabbitPhotosInitial) {
              child = Container(
                  margin: const EdgeInsets.only(
                    top: 2.0,
                    bottom: 2.0,
                    left: 8.0,
                    right: 2.0,
                  ),
                  child: const Center(
                    child: CircularProgressIndicator(),
                  ));
            } else if (state is RabbitPhotosDefaultPhoto) {
              child = Container(
                margin: const EdgeInsets.only(
                  top: 2.0,
                  bottom: 2.0,
                  left: 8.0,
                  right: 2.0,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  image: DecorationImage(
                    image: MemoryImage(
                      state.photo.data,
                    ),
                    fit: BoxFit.cover,
                  ),
                ),
              );
            } else {
              child = const Card(
                margin: EdgeInsets.only(
                  top: 2.0,
                  bottom: 2.0,
                  left: 8.0,
                  right: 2.0,
                ),
                child: Center(
                  child: Icon(
                    Icons.photo,
                  ),
                ),
              );
            }

            return AspectRatio(
              aspectRatio: 1.0,
              child: GestureDetector(
                onTap: () async {
                  await context.push('/rabbit/${rabbit.id}/photos', extra: {
                    'rabbitName': rabbit.name,
                  });
                  if (context.mounted) {
                    context.read<RabbitPhotosBloc>().add(
                          const RabbitPhotosGetDefaultPhoto(),
                        );
                  }
                },
                child: child,
              ),
            );
          },
        ),
      ),
    );
  }
}
