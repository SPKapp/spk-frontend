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
  Uint8List? _photo;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => RabbitPhotosBloc(
        rabbitId: widget.rabbitId,
        storageAuthRepository: context.read<IStorageAuthRepository>(),
      )..add(const RabbitPhotosLoadPhotos())
      // )..downloadPhoto(1),
      ,
      child: BlocListener<RabbitPhotosBloc, RabbitPhotosState>(
        listener: (context, state) {
          print('Listener: $state');
          // context.read<RabbitPhotosCubit>().fetch();
          // if (state is RabbitPhotoDownloaded) {
          //   setState(() {
          //     _photo = state.photo;
          //   });
          // }
        },
        child: Scaffold(
          appBar: AppBar(
            title: Text(widget.rabbitName ?? 'Zdjęcia królika'),
            actions: [
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
            itemCount: 8,
            onPageChanged: (index) {
              _currentIndex = index;
            },
            builder: (context, index) {
              return PhotoViewGalleryPageOptions(
                imageProvider: ((_photo != null)
                    ? MemoryImage(_photo!)
                    : NetworkImage(
                        '',
                      )) as ImageProvider<Object>,
                // minScale: PhotoViewComputedScale.contained,
                // maxScale: PhotoViewComputedScale.covered * 2,
              );
            },
          ),
        ),
      ),
    );
  }
}
