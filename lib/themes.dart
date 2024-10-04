import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:system_theme/system_theme.dart';

const pdsurfaceContainer = Color(0xFF0C0C0C);
const pdsurfaceContainerHigh = Color(0xFF131313);
const pdsurfaceContainerHighest = Color(0xFF1B1B1B);

TextTheme? currentTextTheme;

PageTransitionsTheme customPageTransition = const PageTransitionsTheme(
  builders: <TargetPlatform, PageTransitionsBuilder>{
    TargetPlatform.android: SharedAxisPageTransitionsBuilder(
      transitionType: SharedAxisTransitionType.horizontal,
    ),
  },
);

class CustomTheme {
  final String? bodyFontString;
  final String? displayFontString;
  final ThemeData light_;
  final ThemeData dark_;
  final String name;

  // tachoymi, i kinda copied your code for the themes XD

  CustomTheme ({
    required this.light_,
    required this.dark_,
    required this.name,
    this.bodyFontString,
    this.displayFontString
  });


  ThemeData get colorLight {
    return light_.copyWith(
      pageTransitionsTheme: customPageTransition,
      brightness: Brightness.light,
      textTheme: textLight
    );
  }

  ThemeData get colorDark {
    return dark_.copyWith(
      pageTransitionsTheme: customPageTransition,
      brightness: Brightness.dark,
      textTheme: textDark
    );
  }

  TextTheme get textLight {
    if (bodyFontString == null || displayFontString == null) {
      return light_.textTheme;
    } else {
      return createTextTheme(light_.textTheme, bodyFontString!, displayFontString!);
    }
  }

  TextTheme get textDark {
    if (bodyFontString == null || displayFontString == null) {
      return dark_.textTheme;
    } else {
      return createTextTheme(dark_.textTheme, bodyFontString!, displayFontString!);
    }
  }

  ThemeData getDarkMode(bool providerValue){
    if (providerValue == false) return colorDark;
    // else pure dark
    return ThemeData(
      pageTransitionsTheme: customPageTransition,
      brightness: Brightness.dark,
      textTheme: colorDark.textTheme,
      colorScheme: dark_.colorScheme.copyWith(
        surface: Colors.black,
        onSurface: Colors.white,
        surfaceContainerLowest: pdsurfaceContainer,
        surfaceContainerLow: pdsurfaceContainer,
        surfaceContainer: pdsurfaceContainer, // Navigation bar background
        surfaceContainerHigh: pdsurfaceContainerHigh,
        surfaceContainerHighest: pdsurfaceContainerHighest,
      )
    );
  }
}

TextTheme createTextTheme(TextTheme baseColor, String bodyFontString, String displayFontString) {
  TextTheme bodyTextTheme = GoogleFonts.getTextTheme(bodyFontString, baseColor);
  TextTheme displayTextTheme = GoogleFonts.getTextTheme(displayFontString, baseColor);
  TextTheme textTheme = displayTextTheme.copyWith(
    bodyLarge: bodyTextTheme.bodyLarge,
    bodyMedium: bodyTextTheme.bodyMedium,
    bodySmall: bodyTextTheme.bodySmall,
    labelLarge: bodyTextTheme.labelLarge,
    labelMedium: bodyTextTheme.labelMedium,
    labelSmall: bodyTextTheme.labelSmall,
  );
  return textTheme;
}

CustomTheme dynamic = CustomTheme (
  name: 'System dynamic',
  light_: ThemeData(
    colorScheme: ColorScheme.fromSeed(seedColor: SystemTheme.accentColor.accent, brightness: Brightness.light, dynamicSchemeVariant: DynamicSchemeVariant.fidelity),
  ),
  dark_: ThemeData(
    colorScheme: ColorScheme.fromSeed(seedColor: SystemTheme.accentColor.accent, brightness: Brightness.dark, dynamicSchemeVariant: DynamicSchemeVariant.fidelity),
  ),
  bodyFontString: "Noto Sans Hatran",
  displayFontString: "Noto Sans",
);

CustomTheme deepOrangeTheme = CustomTheme (
  name: 'Deep Orange',
  light_: ThemeData(
    colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrange, brightness: Brightness.light),

  ),
  dark_: ThemeData(
    colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrange, brightness: Brightness.dark),
  ),
  bodyFontString: "Noto Sans Hatran",
  displayFontString: "Noto Sans",
);

CustomTheme mizukiTheme = CustomTheme (
  name: 'Mizuki',
  light_: ThemeData(
    colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue[900]!, brightness: Brightness.light),

  ),
  dark_: ThemeData(
    colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue[900]!, brightness: Brightness.dark),
  ),
  bodyFontString: "Noto Sans Hatran",
  displayFontString: "Noto Sans",
);

CustomTheme ggTheme = CustomTheme (
  name: 'Golden Glow',
  light_ : ThemeData(
    colorScheme: ColorScheme.fromSeed(seedColor: Colors.pink[200]!, brightness: Brightness.light, dynamicSchemeVariant: DynamicSchemeVariant.tonalSpot),
  ),
  dark_: ThemeData(
    colorScheme: ColorScheme.fromSeed(seedColor: Colors.pink[200]!, brightness: Brightness.dark, dynamicSchemeVariant: DynamicSchemeVariant.tonalSpot),
  ),
  bodyFontString: "Noto Sans Hatran",
  displayFontString: "Noto Sans",
);

CustomTheme wTheme = CustomTheme (
  name: 'W',
  light_: ThemeData(
    colorScheme: ColorScheme.light(
      primary : Color(0xFFFF0000),
        onPrimary : Color(0xFFFFFFFF),
        primaryContainer : Color(0xFFFF0000),
        onPrimaryContainer : Color(0xFFFFFFFF),
        inversePrimary : Color(0xFF6D0D0B), // Assuming 'inversePrimary' maps to 'doom_primaryInverse'
        secondary : Color(0xFFFF0000),
        onSecondary : Color(0xFFFFFFFF),
        secondaryContainer : Color(0xFFFF0000),
        onSecondaryContainer : Color(0xFFFFFFFF),
        tertiary : Color(0xFFBFBFBF),
        onTertiary : Color(0xFFFF0000),
        tertiaryContainer : Color(0xFFBFBFBF),
        onTertiaryContainer : Color(0xFFFF0000),
        surface : Color(0xFF212121),
        onSurface : Color(0xFFFFFFFF),
        onSurfaceVariant : Color(0xFFD84945),
        surfaceTint : Color(0xFFFF0000), // Assuming 'surfaceTint' maps to 'doom_primary' or similar
        inverseSurface : Color(0xFF424242),
        onInverseSurface : Color(0xFFFAFAFA),
        outline : Color(0xFFFF0000),
    )
  ),
  dark_: ThemeData(
    colorScheme: ColorScheme.dark(
      primary : Color(0xFFFF0000),
      onPrimary : Color(0xFFFAFAFA),
      primaryContainer : Color(0xFFFF0000),
      onPrimaryContainer : Color(0xFFFAFAFA),
      secondary : Color(0xFFFF0000),
      onSecondary : Color(0xFFFAFAFA),
      secondaryContainer : Color(0xFFFF0000),
      onSecondaryContainer : Color(0xFFFAFAFA),
      tertiary : Color(0xFFBFBFBF),
      onTertiary : Color(0xFFFF0000),
      tertiaryContainer : Color(0xFFBFBFBF),
      onTertiaryContainer : Color(0xFFFF0000),
      surface : Color(0xFF1B1B1B),
      onSurface : Color(0xFFFFFFFF),
      onSurfaceVariant : Color(0xFFD8FFFF),
      surfaceTint : Color(0xFFFF0000),
      inverseSurface : Color(0xFFFAFAFA),
      onInverseSurface : Color(0xFF313131),
      outline : Color(0xFFFF0000),
      inversePrimary : Color(0xFF6D0D0B),
    )
  ),
  bodyFontString: "Noto Sans Hatran",
  displayFontString: "Noto Sans",
);

List<CustomTheme> allCustomThemesList = [dynamic, deepOrangeTheme, mizukiTheme, ggTheme, wTheme];