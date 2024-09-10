import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:docsprts/global_data.dart' as globals;

const pdsurfaceContainer = Color(0xFF0C0C0C);
const pdsurfaceContainerHigh = Color(0xFF131313);
const pdsurfaceContainerHighest = Color(0xFF1B1B1B);

class CustomTheme {
  final TextTheme? text;
  final ThemeData light;
  final ThemeData dark;

  // tachoymi, i kinda copied your code for the themes XD
 
  

  const CustomTheme ({
    this.text,
    required this.light,
    required this.dark,
  });
  

  ThemeData getDarkMode(){
    if (globals.themePureDark == false) return dark;
    // else pure dark
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: dark.colorScheme.copyWith(
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

TextTheme createTextTheme(BuildContext context, String bodyFontString, String displayFontString) {
  TextTheme baseTextTheme = Theme.of(context).textTheme;
  TextTheme bodyTextTheme = GoogleFonts.getTextTheme(bodyFontString, baseTextTheme);
  TextTheme displayTextTheme =
      GoogleFonts.getTextTheme(displayFontString, baseTextTheme);
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

CustomTheme deepOrangeTheme = CustomTheme(
  light: ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrange, brightness: Brightness.light),
    brightness: Brightness.light,
  ),
  dark: ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrange, brightness: Brightness.dark),
    brightness: Brightness.dark,
  )
);


