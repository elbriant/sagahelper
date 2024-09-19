import 'dart:math';

import 'package:docsprts/providers/ui_provider.dart';
import 'package:docsprts/themes.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ThemePreview extends StatelessWidget {
  final CustomTheme previewedTheme;
  final int selfIndex;
  final bool thisSelected;
  final InkWell inkWellChild;
  const ThemePreview({super.key, required this.selfIndex, required this.previewedTheme, required this.thisSelected, required this.inkWellChild});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 25),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded (
            flex: 9,
            child: Container (
              width: 90,
              height: 180,
              clipBehavior: Clip.hardEdge,
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(14), border: Border.all(strokeAlign: BorderSide.strokeAlignOutside , width: 6, color: thisSelected ? (Theme.of(context).brightness == Brightness.light ? previewedTheme.colorLight.colorScheme.primary : previewedTheme.getDarkMode(context.read<UiProvider>().isUsingPureDark).colorScheme.primary) : ((Theme.of(context).brightness == Brightness.light ? previewedTheme.colorLight.colorScheme.surfaceContainerHighest : previewedTheme.getDarkMode(context.read<UiProvider>().isUsingPureDark).colorScheme.surfaceContainerHighest)))),
              child: Stack(
                children: [
                  InnerCard(previewedTheme: previewedTheme, thisSelected: thisSelected),
                  Material(
                    type: MaterialType.transparency,
                    child: inkWellChild,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(flex: 1, child: Text(previewedTheme.name, style: TextStyle(color: Theme.of(context).brightness == Brightness.light ? (previewedTheme.colorLight.colorScheme.secondary) : (previewedTheme.colorDark.colorScheme.secondary))))
        ],
      ),
    );
  }
}

class InnerCard extends StatelessWidget {
  const InnerCard({super.key, required this.previewedTheme, required this.thisSelected});
  final CustomTheme previewedTheme;
  final bool thisSelected;

  @override
  Widget build(BuildContext context) {
    
  bool getCurrentBrightness () {
    return Theme.of(context).brightness == Brightness.light;
  }

  bool usingPureDark () {
    return context.read<UiProvider>().isUsingPureDark;
  }

  bool usingTraslucent () {
    return context.read<UiProvider>().useTranslucentUi;
  }

  ColorScheme lightColorScheme = previewedTheme.colorLight.colorScheme;
  ColorScheme darkColorScheme = previewedTheme.getDarkMode(usingPureDark()).colorScheme;

    return Flex(
      direction: Axis.vertical,
      children: [
        Expanded(
          flex: 3,
          child: Container(
            color: getCurrentBrightness() ? (usingTraslucent() ? lightColorScheme.surfaceContainer.withOpacity(0.5) : lightColorScheme.surfaceContainer) : (usingTraslucent() ? darkColorScheme.surfaceContainer.withOpacity(0.5) : darkColorScheme.surfaceContainer) ,
            child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const SizedBox(width: 12),
                CustomPaint(size: const Size(40, 5), painter: TitleLine(color: getCurrentBrightness() ? (lightColorScheme.onPrimaryContainer) : (darkColorScheme.onPrimaryContainer)),
                ),
                const SizedBox(width: 5),
                thisSelected ? Icon(Icons.check_circle, size: 20, color: getCurrentBrightness() ? (lightColorScheme.primary) : (darkColorScheme.primary)) : Container()
              ],
            ),
          ),
        ),
        Expanded(
          flex: 9,
          child: Container(
            color: getCurrentBrightness() ? (lightColorScheme.surface) : (darkColorScheme.surface),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: CustomPaint(size: const Size(double.maxFinite, 5), painter: TitleLine(color: getCurrentBrightness() ? (lightColorScheme.primary) : (darkColorScheme.primary))),
                ),
                Container(
                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(8.0), color: getCurrentBrightness() ? (lightColorScheme.primaryContainer) : (darkColorScheme.primaryContainer)),
                  margin: const EdgeInsets.fromLTRB(6, 2, 6, 10),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: CustomPaint(size: const Size(double.maxFinite, 5), painter: TitleLine(color: getCurrentBrightness() ? (lightColorScheme.onPrimaryContainer) : (darkColorScheme.onPrimaryContainer))),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30.0),
                  child: CustomPaint(size: const Size(double.maxFinite, 5), painter: TitleLine(color: getCurrentBrightness() ? (lightColorScheme.onSurface) : (darkColorScheme.onSurface))),
                )
              ],
            ),
          ),
        ),
        Expanded(
          flex: 3,
          child: Container(
            color: getCurrentBrightness() ? (usingTraslucent() ? lightColorScheme.surfaceContainer.withOpacity(0.5) : lightColorScheme.surfaceContainer) : (usingTraslucent() ? darkColorScheme.surfaceContainer.withOpacity(0.5) : darkColorScheme.surfaceContainer),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  flex: 3,
                  child: Container(
                    margin: const EdgeInsets.fromLTRB(8, 2, 0, 2),
                    decoration: BoxDecoration(shape: BoxShape.circle, color: getCurrentBrightness() ? (lightColorScheme.primary) : (darkColorScheme.primary))
                  )
                ),
                const SizedBox(width: 6),
                Expanded(
                  flex: 7,
                  child: Container(
                    margin: const EdgeInsets.fromLTRB(0, 8, 8, 8),
                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(16), shape: BoxShape.rectangle, color: getCurrentBrightness() ? (lightColorScheme.outline) : (darkColorScheme.outline))
                  )
                )
              ],
            ),
          ),
        )
      ],
    );
  }
}


class TitleLine extends CustomPainter {
  const TitleLine({this.color = Colors.black});
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    Path path = Path();
    // why the fk i wasted 2 hours doing this
    for (double n = 0.5; n < size.width; n+=0.5) {
      var x = n;
      var y = size.height / 2 + -((sqrt(x*4)/pow(x, 2))*sin(x)*x)*3 ;
      path.lineTo(x, y);
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}