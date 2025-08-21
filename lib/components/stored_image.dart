// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:network_to_file_image/network_to_file_image.dart';

import 'package:sagahelper/models/config/local_data_manager.dart';
import 'package:transparent_image/transparent_image.dart';

/// create a cacheable image that fades in
/// if image cant be loaded, it will remain transparent
class StoredFadeInImage extends StatelessWidget {
  const StoredFadeInImage({
    super.key,
    required this.filename,
    required this.imageUrl,
    this.quality = FilterQuality.medium,
    this.width,
    this.height,
    this.type,
  });

  final String filename;
  final String imageUrl;
  final double? width;
  final double? height;
  final FilterQuality quality;
  final CacheType? type;

  @override
  Widget build(BuildContext context) {
    return FadeInImage(
      placeholder: MemoryImage(kTransparentImage),
      image: NetworkToFileImage(
        url: imageUrl,
        file: LocalDataManager.localCacheFile(filename, type),
      ),
      imageErrorBuilder: (context, error, stackTrace) => Image.memory(
        kTransparentImage,
        width: width,
        height: height,
      ),
    );
  }
}
