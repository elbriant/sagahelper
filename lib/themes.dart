import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

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

List<CustomTheme> allCustomThemesList = [deepOrangeTheme, deepOrangeTheme, mizukiTheme];