import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:math';

import 'package:sagahelper/core/themes.dart';
import 'package:flutter/material.dart';
import 'package:sagahelper/providers/config_provider.dart';

class ThemePreview extends ConsumerWidget {
  final CustomTheme previewedTheme;
  final int selfIndex;
  final bool thisSelected;
  final InkWell inkWellChild;
  const ThemePreview({
    super.key,
    required this.selfIndex,
    required this.previewedTheme,
    required this.thisSelected,
    required this.inkWellChild,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final usePureDark = ref.watch(configProvider.select((p) => p.usePureDarkTheme));
    final brightness = Theme.of(context).brightness;
    final colorScheme =
        previewedTheme.fromBrightnessAndPureDark(brightness, usePureDark).colorScheme;

    return Container(
      margin: const EdgeInsets.fromLTRB(5, 10, 15, 5),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            flex: 9,
            child: Container(
              width: 90,
              height: 180,
              clipBehavior: Clip.hardEdge,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  strokeAlign: BorderSide.strokeAlignOutside,
                  width: 6,
                  color: thisSelected ? colorScheme.primary : colorScheme.surfaceContainerHighest,
                ),
              ),
              child: Stack(
                children: [
                  InnerCard(
                    previewedTheme: previewedTheme,
                    thisSelected: thisSelected,
                  ),
                  Material(
                    type: MaterialType.transparency,
                    child: inkWellChild,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            flex: 1,
            child: Text(
              previewedTheme.name,
              style: TextStyle(
                color: colorScheme.secondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class InnerCard extends ConsumerWidget {
  const InnerCard({
    super.key,
    required this.previewedTheme,
    required this.thisSelected,
  });
  final CustomTheme previewedTheme;
  final bool thisSelected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final usePureDark = ref.watch(configProvider.select((p) => p.usePureDarkTheme));
    final useTranslucentUi = ref.watch(configProvider.select((p) => p.useTranslucentUi));
    final brightness = Theme.of(context).brightness;
    final colorScheme =
        previewedTheme.fromBrightnessAndPureDark(brightness, usePureDark).colorScheme;

    return Flex(
      direction: Axis.vertical,
      children: [
        Expanded(
          flex: 3,
          child: Stack(
            fit: StackFit.expand,
            alignment: Alignment.center,
            children: [
              Container(
                color: colorScheme.surface,
              ),
              Container(
                color: useTranslucentUi
                    ? colorScheme.surfaceContainer.withValues(alpha: 0.5)
                    : colorScheme.surfaceContainer,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    const SizedBox(width: 12),
                    CustomPaint(
                      size: const Size(40, 5),
                      painter: TitleLine(
                        color: colorScheme.onPrimaryContainer,
                      ),
                    ),
                    const SizedBox(width: 5),
                    thisSelected
                        ? Icon(
                            Icons.check_circle,
                            size: 20,
                            color: colorScheme.primary,
                          )
                        : Container(),
                  ],
                ),
              ),
            ],
          ),
        ),
        Expanded(
          flex: 9,
          child: Container(
            color: colorScheme.surface,
            child: Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: CustomPaint(
                    size: const Size(double.maxFinite, 5),
                    painter: TitleLine(
                      color: colorScheme.primary,
                    ),
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8.0),
                    color: colorScheme.primaryContainer,
                  ),
                  margin: const EdgeInsets.fromLTRB(6, 2, 6, 10),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: CustomPaint(
                      size: const Size(double.maxFinite, 5),
                      painter: TitleLine(
                        color: colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30.0),
                  child: CustomPaint(
                    size: const Size(double.maxFinite, 5),
                    painter: TitleLine(
                      color: colorScheme.onSurface,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        Expanded(
          flex: 3,
          child: Stack(
            fit: StackFit.expand,
            alignment: Alignment.center,
            children: [
              Container(
                color: colorScheme.surface,
              ),
              Container(
                color: useTranslucentUi
                    ? colorScheme.surfaceContainer.withValues(alpha: 0.5)
                    : colorScheme.surfaceContainer,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      flex: 3,
                      child: Container(
                        margin: const EdgeInsets.fromLTRB(8, 2, 0, 2),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: colorScheme.primary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      flex: 7,
                      child: Container(
                        margin: const EdgeInsets.fromLTRB(0, 8, 8, 8),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          shape: BoxShape.rectangle,
                          color: colorScheme.outline,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
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
    for (double n = 0.5; n < size.width; n += 0.5) {
      var x = n;
      var y = size.height / 2 + -((sqrt(x * 4) / pow(x, 2)) * sin(x) * x) * 3;
      path.lineTo(x, y);
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
