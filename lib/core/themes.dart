import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:system_theme/system_theme.dart';

const pdsurfaceContainer = Color(0xFF0C0C0C);
const pdsurfaceContainerHigh = Color(0xFF131313);
const pdsurfaceContainerHighest = Color(0xFF1B1B1B);
const customPageTransition = PageTransitionsTheme(
  builders: <TargetPlatform, PageTransitionsBuilder>{
    TargetPlatform.android: SharedAxisPageTransitionsBuilder(
      transitionType: SharedAxisTransitionType.horizontal,
    ),
  },
);

TextTheme createTextTheme(
  TextTheme baseTheme,
  String? bodyFontString,
  String? displayFontString,
) {
  TextTheme? bodyTextTheme =
      bodyFontString != null ? GoogleFonts.getTextTheme(bodyFontString, baseTheme) : null;
  TextTheme? displayTextTheme =
      displayFontString != null ? GoogleFonts.getTextTheme(displayFontString, baseTheme) : null;
  TextTheme textTheme = displayTextTheme?.copyWith(
        bodyLarge: bodyTextTheme?.bodyLarge,
        bodyMedium: bodyTextTheme?.bodyMedium,
        bodySmall: bodyTextTheme?.bodySmall,
        labelLarge: bodyTextTheme?.labelLarge,
        labelMedium: bodyTextTheme?.labelMedium,
        labelSmall: bodyTextTheme?.labelSmall,
      ) ??
      baseTheme.copyWith(
        bodyLarge: bodyTextTheme?.bodyLarge,
        bodyMedium: bodyTextTheme?.bodyMedium,
        bodySmall: bodyTextTheme?.bodySmall,
        labelLarge: bodyTextTheme?.labelLarge,
        labelMedium: bodyTextTheme?.labelMedium,
        labelSmall: bodyTextTheme?.labelSmall,
      );
  return textTheme;
}

class CustomTheme {
  final String? bodyFontString;
  final String? displayFontString;
  final ThemeData rawLight;
  final ThemeData rawDark;
  final String name;

  // tachoymi, i kinda copied your code for the themes XD
  CustomTheme({
    required this.rawLight,
    required this.rawDark,
    required this.name,
    this.bodyFontString,
    this.displayFontString,
  });

  ThemeData get themeLight {
    return rawLight.copyWith(
      pageTransitionsTheme: customPageTransition,
      brightness: Brightness.light,
      textTheme: createTextTheme(rawLight.textTheme, bodyFontString, displayFontString),
    );
  }

  ThemeData get themeDark {
    return rawDark.copyWith(
      pageTransitionsTheme: customPageTransition,
      brightness: Brightness.dark,
      textTheme: createTextTheme(rawDark.textTheme, bodyFontString, displayFontString),
    );
  }

  ThemeData get themePureDark {
    return themeDark.copyWith(
      scaffoldBackgroundColor: Colors.black,
      colorScheme: themeDark.colorScheme.copyWith(
        surface: Colors.black,
        onSurface: Colors.white,
        surfaceContainerLowest: pdsurfaceContainer,
        surfaceContainerLow: pdsurfaceContainer,
        surfaceContainer: pdsurfaceContainer, // Navigation bar background
        surfaceContainerHigh: pdsurfaceContainerHigh,
        surfaceContainerHighest: pdsurfaceContainerHighest,
      ),
    );
  }

  ThemeData getDarkMode(bool pureDark) {
    return pureDark ? themePureDark : themeDark;
  }

  /// just light or dark, pure dark gets ignored
  ThemeData fromBrightness(Brightness brightness) {
    return brightness == Brightness.light ? themeLight : themeDark;
  }

  /// just light or dark or pure dark
  ThemeData fromBrightnessAndPureDark(Brightness brightness, bool pureDark) {
    return brightness == Brightness.light ? themeLight : getDarkMode(pureDark);
  }

  factory CustomTheme.fast(Color color) {
    return CustomTheme(
      name: 'Fast',
      rawLight: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: color,
          brightness: Brightness.light,
          dynamicSchemeVariant: DynamicSchemeVariant.vibrant,
        ),
      ),
      rawDark: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: color,
          brightness: Brightness.dark,
          dynamicSchemeVariant: DynamicSchemeVariant.vibrant,
        ),
      ),
    );
  }
}

final CustomTheme dynamicTheme = CustomTheme(
  name: 'System dynamic',
  rawLight: ThemeData(
    colorScheme: ColorScheme.fromSeed(
      seedColor: SystemTheme.accentColor.accent,
      brightness: Brightness.light,
      dynamicSchemeVariant: DynamicSchemeVariant.vibrant,
    ),
  ),
  rawDark: ThemeData(
    colorScheme: ColorScheme.fromSeed(
      seedColor: SystemTheme.accentColor.accent,
      brightness: Brightness.dark,
      dynamicSchemeVariant: DynamicSchemeVariant.vibrant,
    ),
  ),
  bodyFontString: "Noto Sans Hatran",
  displayFontString: "Noto Sans",
);

final CustomTheme deepOrangeTheme = CustomTheme(
  name: 'Deep Orange',
  rawLight: ThemeData(
    colorScheme: ColorScheme.fromSeed(
      seedColor: Colors.deepOrange,
      brightness: Brightness.light,
    ),
  ),
  rawDark: ThemeData(
    colorScheme: ColorScheme.fromSeed(
      seedColor: Colors.deepOrange,
      brightness: Brightness.dark,
    ),
  ),
  bodyFontString: "Noto Sans Hatran",
  displayFontString: "Noto Sans",
);

final CustomTheme mizukiTheme = CustomTheme(
  name: 'Mizuki',
  rawLight: ThemeData(
    colorScheme: ColorScheme.fromSeed(
      seedColor: Colors.blue[900]!,
      brightness: Brightness.light,
    ),
  ),
  rawDark: ThemeData(
    colorScheme: ColorScheme.fromSeed(
      seedColor: Colors.blue[900]!,
      brightness: Brightness.dark,
    ),
  ),
  bodyFontString: "Noto Sans Hatran",
  displayFontString: "Noto Sans",
);

final CustomTheme ggTheme = CustomTheme(
  name: 'Golden Glow',
  rawLight: ThemeData(
    colorScheme: ColorScheme.fromSeed(
      seedColor: Colors.pink[200]!,
      brightness: Brightness.light,
      dynamicSchemeVariant: DynamicSchemeVariant.tonalSpot,
    ),
  ),
  rawDark: ThemeData(
    colorScheme: ColorScheme.fromSeed(
      seedColor: Colors.pink[200]!,
      brightness: Brightness.dark,
      dynamicSchemeVariant: DynamicSchemeVariant.tonalSpot,
    ),
  ),
  bodyFontString: "Noto Sans Hatran",
  displayFontString: "Noto Sans",
);

final CustomTheme wTheme = CustomTheme(
  name: 'W',
  rawLight: ThemeData(
    colorScheme: const ColorScheme.light(
      primary: Color(0xFFFF0000),
      onPrimary: Color(0xFFFFFFFF),
      primaryContainer: Color(0xFFFF0000),
      onPrimaryContainer: Color(0xFFFFFFFF),
      inversePrimary: Color(
        0xFF6D0D0B,
      ), // Assuming 'inversePrimary' maps to 'doom_primaryInverse'
      secondary: Color(0xFFFF0000),
      onSecondary: Color(0xFFFFFFFF),
      secondaryContainer: Color(0xFFFF0000),
      onSecondaryContainer: Color(0xFFFFFFFF),
      tertiary: Color(0xFFBFBFBF),
      onTertiary: Color(0xFFFF0000),
      tertiaryContainer: Color(0xFFBFBFBF),
      onTertiaryContainer: Color(0xFFFF0000),
      surface: Color(0xFF212121),
      onSurface: Color(0xFFFFFFFF),
      onSurfaceVariant: Color(0xFFD84945),
      surfaceTint: Color(
        0xFFFF0000,
      ), // Assuming 'surfaceTint' maps to 'doom_primary' or similar
      inverseSurface: Color(0xFF424242),
      onInverseSurface: Color(0xFFFAFAFA),
      outline: Color(0xFFFF0000),
    ),
  ),
  rawDark: ThemeData(
    colorScheme: const ColorScheme.dark(
      primary: Color(0xFFFF0000),
      onPrimary: Color(0xFFFAFAFA),
      primaryContainer: Color(0xFFFF0000),
      onPrimaryContainer: Color(0xFFFAFAFA),
      secondary: Color(0xFFFF0000),
      onSecondary: Color(0xFFFAFAFA),
      secondaryContainer: Color(0xFFFF0000),
      onSecondaryContainer: Color(0xFFFAFAFA),
      tertiary: Color(0xFFBFBFBF),
      onTertiary: Color(0xFFFF0000),
      tertiaryContainer: Color(0xFFBFBFBF),
      onTertiaryContainer: Color(0xFFFF0000),
      surface: Color(0xFF1B1B1B),
      onSurface: Color(0xFFFFFFFF),
      onSurfaceVariant: Color(0xFFD8FFFF),
      surfaceTint: Color(0xFFFF0000),
      inverseSurface: Color(0xFFFAFAFA),
      onInverseSurface: Color(0xFF313131),
      outline: Color(0xFFFF0000),
      inversePrimary: Color(0xFF6D0D0B),
    ),
  ),
  bodyFontString: "Noto Sans Hatran",
  displayFontString: "Noto Sans",
);

final List<CustomTheme> allCustomThemes = [
  dynamicTheme,
  deepOrangeTheme,
  mizukiTheme,
  ggTheme,
  wTheme,
];
