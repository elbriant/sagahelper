import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:sagahelper/core/themes.dart';
import 'package:sagahelper/models/config/local_data_manager.dart';
import 'package:sagahelper/providers/config_provider.dart';

/// AutoDispose family provider that extracts dominant color from operator avatar
/// and generates a CustomTheme for the operator page.
///
/// Safe for early dispose: if the user leaves before processing completes,
/// the provider disposes cleanly without errors.
final operatorColorThemeProvider = FutureProvider.autoDispose
    .family<CustomTheme?, String>((ref, operatorId) async {
  final enabled =
      ref.watch(configProvider.select((p) => p.useOperatorColorTheme));
  if (!enabled) return null;

  final cacheFile = LocalDataManager.localCacheFile(
    '${operatorId}_dl0.png',
    CacheType.operatorAvatar,
  );

  if (!cacheFile.existsSync()) return null;

  try {
    final palette = await PaletteGenerator.fromImageProvider(
      FileImage(cacheFile),
      maximumColorCount: 32,
    );

    final seedColor = _pickBestSeedColor(palette);
    if (seedColor == null) return null;

    final variant = _pickSchemeVariant(seedColor);

    return CustomTheme(
      name: 'Operator',
      rawLight: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: seedColor,
          brightness: Brightness.light,
          dynamicSchemeVariant: variant,
        ),
      ),
      rawDark: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: seedColor,
          brightness: Brightness.dark,
          dynamicSchemeVariant: variant,
        ),
      ),
    );
  } catch (_) {
    return null;
  }
});

/// Picks the best seed color using population-weighted scoring.
/// All colors compete fairly based on how much of the image they cover.
Color? _pickBestSeedColor(PaletteGenerator palette) {
  final allColors = palette.paletteColors;
  if (allColors.isEmpty) return null;

  final totalPopulation =
      allColors.fold<int>(0, (sum, c) => sum + c.population);

  PaletteColor? best;
  double bestScore = double.negativeInfinity;

  for (final c in allColors) {
    final hsl = HSLColor.fromColor(c.color);
    final populationRatio = c.population / totalPopulation;
    final score = populationRatio * (0.6 + hsl.saturation * 0.4);

    if (score > bestScore) {
      bestScore = score;
      best = c;
    }
  }

  best ??= palette.dominantColor;
  return best?.color;
}

/// Picks a scheme variant based on the seed color's characteristics.
DynamicSchemeVariant _pickSchemeVariant(Color color) {
  final hsl = HSLColor.fromColor(color);

  if (hsl.saturation < 0.15) {
    return DynamicSchemeVariant.monochrome;
  }
  if (hsl.saturation < 0.3) {
    return DynamicSchemeVariant.tonalSpot;
  }
  if (hsl.lightness < 0.35 && hsl.saturation > 0.4) {
    return DynamicSchemeVariant.expressive;
  }
  if (hsl.lightness > 0.65) {
    return DynamicSchemeVariant.content;
  }
  return DynamicSchemeVariant.vibrant;
}
