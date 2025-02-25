import 'dart:io';

import 'package:flutter/material.dart';
import 'package:network_to_file_image/network_to_file_image.dart';
import 'package:sagahelper/global_data.dart';

class StoredImage extends StatelessWidget {
  const StoredImage({
    super.key,
    this.filePath,
    this.imageUrl,
    this.heroTag,
    this.color,
    this.colorBlendMode,
    this.fit = BoxFit.contain,
    this.scale = 1.0,
    this.alignment = Alignment.center,
    this.filterQuality = FilterQuality.medium,
    this.placeholder,
    this.showProgress = true,
    this.useSync = true,
    this.width,
    this.height,
  });

  final String? filePath;
  final String? imageUrl;
  final String? heroTag;
  final Color? color;
  final BlendMode? colorBlendMode;
  final BoxFit fit;
  final double scale;
  final AlignmentGeometry alignment;
  final FilterQuality filterQuality;
  final Widget? placeholder;
  final bool showProgress;
  final bool useSync;
  final double? width;
  final double? height;

  @override
  Widget build(BuildContext context) {
    assert(filePath != null || imageUrl != null);

    if (!useSync) {
      Future<File?> imgFile;

      if (filePath != null) {
        imgFile = LocalDataManager.localCacheFile(
          filePath!,
          true,
        );
      } else {
        imgFile = Future.value(null);
      }

      return FutureBuilder(
        future: imgFile,
        builder: (context, snapshot) {
          final prepPlaceholder = showProgress
              ? Center(
                  child: Stack(
                    children: [
                      placeholder ?? const SizedBox.shrink(),
                      const CircularProgressIndicator(),
                    ],
                  ),
                )
              : placeholder ?? const SizedBox.shrink();

          if (!snapshot.hasData) {
            return heroTag != null
                ? Hero(
                    tag: heroTag!,
                    child: prepPlaceholder,
                  )
                : prepPlaceholder;
          }

          final image = Image(
            image: NetworkToFileImage(
              url: imageUrl,
              file: snapshot.data!,
              scale: scale,
            ),
            fit: fit,
            color: color,
            width: width,
            height: height,
            alignment: alignment,
            colorBlendMode: colorBlendMode,
            filterQuality: filterQuality,
            errorBuilder: (context, error, stackTrace) {
              return const Center(child: Icon(Icons.error));
            },
            loadingBuilder: (
              BuildContext context,
              Widget child,
              ImageChunkEvent? loadingProgress,
            ) {
              return AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: loadingProgress == null ? child : prepPlaceholder,
              );
            },
          );

          final prepWidget = heroTag != null
              ? Hero(
                  tag: heroTag!,
                  child: image,
                )
              : image;

          return prepWidget;
        },
      );
    }

    final image = Image(
      image: NetworkToFileImage(
        url: imageUrl,
        file: filePath != null ? LocalDataManager.localCacheFileSync(filePath!) : null,
        scale: scale,
      ),
      fit: fit,
      color: color,
      width: width,
      height: height,
      alignment: alignment,
      colorBlendMode: colorBlendMode,
      filterQuality: filterQuality,
      errorBuilder: (context, error, stackTrace) {
        return const Center(child: Icon(Icons.error));
      },
      loadingBuilder: (
        BuildContext context,
        Widget child,
        ImageChunkEvent? loadingProgress,
      ) {
        if (loadingProgress == null) {
          return child;
        }

        return Stack(
          children: [
            placeholder ?? const SizedBox.shrink(),
            showProgress
                ? Center(
                    child: CircularProgressIndicator(
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded /
                              loadingProgress.expectedTotalBytes!
                          : null,
                    ),
                  )
                : const SizedBox.shrink(),
          ],
        );
      },
    );

    final prepWidget = (heroTag != null)
        ? Hero(
            tag: heroTag!,
            child: image,
          )
        : image;

    return prepWidget;
  }
}
