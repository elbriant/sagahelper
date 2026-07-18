// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:network_to_file_image/network_to_file_image.dart';

import 'package:sagahelper/models/config/local_data_manager.dart';
import 'package:sagahelper/providers/connectivity_provider.dart';
import 'package:sagahelper/utils/extensions.dart';
import 'package:transparent_image/transparent_image.dart';

/// create a cacheable image that fades in
/// if image cant be loaded, it will remain transparent
class StoredFadeInImage extends ConsumerWidget {
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
  Widget build(BuildContext context, WidgetRef ref) {
    final isConnected = ref.watch(effectiveIsConnectedProvider);
    final cacheFile = LocalDataManager.localCacheFile(filename, type);

    // When offline: use local file if cached, otherwise show transparent (no network attempt)
    if (!isConnected) {
      if (cacheFile.existsSync()) {
        return FadeInImage(
          placeholder: MemoryImage(kTransparentImage),
          image: FileImage(cacheFile),
          filterQuality: quality,
          imageErrorBuilder: (context, error, stackTrace) => Image.memory(
            kTransparentImage,
            width: width,
            height: height,
          ),
        );
      }
      return Image.memory(
        kTransparentImage,
        width: width,
        height: height,
      );
    }

    return FadeInImage(
      placeholder: MemoryImage(kTransparentImage),
      image: NetworkToFileImage(
        url: imageUrl,
        file: cacheFile,
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

class StoredCustomImage extends ConsumerWidget {
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
  Widget build(BuildContext context, WidgetRef ref) {
    final isConnected = ref.watch(effectiveIsConnectedProvider);
    final cacheFile = LocalDataManager.localCacheFile(filename, type);

    // When offline: use local file if cached, otherwise show placeholder (no network attempt)
    if (!isConnected) {
      if (cacheFile.existsSync()) {
        return FadeInImage(
          placeholder: placeholder ?? MemoryImage(kTransparentImage, scale: scale),
          placeholderColor: placeholderColor,
          image: FileImage(cacheFile, scale: scale),
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
      return placeholder.isNull
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
            );
    }

    return FadeInImage(
      placeholder: placeholder ?? MemoryImage(kTransparentImage, scale: scale),
      placeholderColor: placeholderColor,
      image: NetworkToFileImage(
        url: imageUrl,
        file: cacheFile,
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
