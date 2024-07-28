import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:photo_view/photo_view_gallery.dart';

import 'package:spk_app_frontend/common/storage/storage.dart';
import 'package:spk_app_frontend/features/rabbit_photos/bloc/rabbit_photos.bloc.dart';

class RabbitPhotosListPage extends StatefulWidget {
  const RabbitPhotosListPage({
    super.key,
    required this.rabbitId,
    this.rabbitName,
  });

  final String rabbitId;
  final String? rabbitName;

  @override
  State<RabbitPhotosListPage> createState() => _RabbitPhotosListPageState();
}

class _RabbitPhotosListPageState extends State<RabbitPhotosListPage> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => RabbitPhotosBloc(
        rabbitId: widget.rabbitId,
        storageAuthRepository: context.read<IStorageAuthRepository>(),
      )..add(const RabbitPhotosLoadPhotos()),
      child: BlocBuilder<RabbitPhotosBloc, RabbitPhotosState>(
        builder: (context, state) {
          if (state is RabbitPhotosList) {
            return Scaffold(
                appBar: AppBar(
                  title: Text(widget.rabbitName ?? 'Zdjęcia królika'),
                  actions: [
                    IconButton(
                      icon: Icon(
                          state.photos[state.names[_currentIndex]] != null &&
                                  state.photos[state.names[_currentIndex]]!
                                      .isDefault
                              ? Icons.star
                              : Icons.star_border_outlined),
                      onPressed: () => context.read<RabbitPhotosBloc>().add(
                            RabbitPhotosSetDefaultPhoto(
                              state.names[_currentIndex],
                            ),
                          ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.download),
                      onPressed: () {
                        print('Download photo with index $_currentIndex');
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () {
                        print('Delete photo with index $_currentIndex');
                      },
                    ),
                  ],
                ),
                floatingActionButton: FloatingActionButton(
                  onPressed: () {
                    print('Add new photo');
                  },
                  child: const Icon(Icons.add),
                ),
                body: PhotoViewGallery.builder(
                    itemCount: state.names.length,
                    onPageChanged: (index) {
                      setState(() {
                        _currentIndex = index;
                      });
                    },
                    builder: (context, index) {
                      final photo = state.photos[state.names[index]];

                      return PhotoViewGalleryPageOptions(
                        imageProvider: MemoryImage(
                          photo != null
                              ? photo.data
                              // throws an error catched by errorBuilder
                              : Uint8List(0),
                        ),
                        errorBuilder: (context, error, stackTrace) => Center(
                          child: photo != null
                              ? const Icon(Icons.error)
                              : const CircularProgressIndicator(),
                        ),
                      );
                    }));
          } else {
            return Scaffold(
              appBar: AppBar(),
              body: const Center(
                child: CircularProgressIndicator(),
              ),
            );
          }
        },
      ),
    );
  }
}
