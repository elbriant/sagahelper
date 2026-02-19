// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:network_to_file_image/network_to_file_image.dart';

import 'package:sagahelper/models/config/local_data_manager.dart';
import 'package:sagahelper/utils/extensions.dart';
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
      filterQuality: quality,
      imageErrorBuilder: (context, error, stackTrace) => Image.memory(
        kTransparentImage,
        width: width,
        height: height,
      ),
    );
  }
}

class StoredCustomImage extends StatelessWidget {
  const StoredCustomImage({
    super.key,
    required this.filename,
    required this.imageUrl,
    this.quality = FilterQuality.medium,
    this.width,
    this.height,
    this.type,
    this.placeholder,
    this.color,
    this.colorBlendMode,
    this.scale = 1.0,
    this.placeholderColor,
    this.placeholderColorBlendMode,
    this.fit,
    this.alignment = Alignment.center,
    this.placeholderFit,
  });

  final String filename;
  final String imageUrl;
  final double? width;
  final double? height;
  final FilterQuality quality;
  final CacheType? type;
  final ImageProvider<Object>? placeholder;
  final Color? placeholderColor;
  final Color? color;
  final BoxFit? fit;
  final BlendMode? colorBlendMode;
  final BlendMode? placeholderColorBlendMode;
  final BoxFit? placeholderFit;

  /// will be the same for placeholder
  final double scale;
  final AlignmentGeometry alignment;

  @override
  Widget build(BuildContext context) {
    return FadeInImage(
      placeholder: placeholder ?? MemoryImage(kTransparentImage, scale: scale),
      placeholderColor: placeholderColor,
      image: NetworkToFileImage(
        url: imageUrl,
        file: LocalDataManager.localCacheFile(filename, type),
        scale: scale,
      ),
      color: color,
      fit: fit,
      colorBlendMode: colorBlendMode,
      placeholderColorBlendMode: placeholderColorBlendMode,
      placeholderFit: placeholderFit,
      filterQuality: quality,
      alignment: alignment,
      imageErrorBuilder: (context, error, stackTrace) => placeholder.isNull
          ? Image.memory(
              kTransparentImage,
              scale: scale,
              width: width,
              height: height,
            )
          : Image(
              image: placeholder!,
              width: width,
              height: height,
            ),
    );
  }
}
