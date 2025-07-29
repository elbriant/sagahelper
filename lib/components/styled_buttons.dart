library;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sagahelper/utils/extensions.dart';
import 'package:sagahelper/global_data.dart';
import 'package:sagahelper/providers/settings_provider.dart';

class IconButtonStyled extends StatelessWidget {
  const IconButtonStyled({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
    this.iconFilled,
    this.selected = false,
    this.size,
    this.textStyle,
  });
  final IconData icon;
  final IconData? iconFilled;
  final String label;
  final bool selected;
  final Function() onTap;
  final Size? size;
  final TextStyle? textStyle;

  @override
  Widget build(BuildContext context) {
    Size sizing = size ?? const Size.square(80);

    return Container(
      constraints: BoxConstraints.loose(sizing),
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(
                selected == true && iconFilled != null ? iconFilled : icon,
                color: selected == true
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.outline,
                size: sizing.width / 3,
              ),
              Text(
                label,
                style: textStyle ??
                    TextStyle(
                      fontSize: sizing.width / 7,
                      color: selected == true
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).colorScheme.outline,
                    ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class StyledLangButton extends StatelessWidget {
  const StyledLangButton({
    super.key,
    required this.label,
    this.sublabel,
    required this.vaName,
    required this.onTap,
    this.selected = false,
  });
  final String label;
  final String? sublabel;
  final String vaName;
  final bool selected;
  final Function() onTap;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          padding: const EdgeInsets.all(4.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: selected
                ? Color.lerp(
                    Theme.of(context).colorScheme.surfaceContainerHigh,
                    Theme.of(context).colorScheme.secondaryContainer,
                    0.05,
                  )
                : Theme.of(context).colorScheme.surfaceContainerHigh,
            border: selected
                ? Border.all(color: Theme.of(context).colorScheme.primary)
                : Border.all(
                    color: Theme.of(context).colorScheme.surfaceContainer,
                  ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(4.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget?>[
                Text(
                  label,
                  textScaler: const TextScaler.linear(1.5),
                  style: selected ? TextStyle(color: Theme.of(context).colorScheme.primary) : null,
                ),
                sublabel != null
                    ? Text(
                        sublabel!,
                        style: selected
                            ? TextStyle(
                                color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.7),
                              )
                            : TextStyle(
                                color:
                                    Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                              ),
                        textScaler: const TextScaler.linear(0.7),
                      )
                    : null,
                const SizedBox(height: 3),
                Text(
                  vaName,
                  style: const TextStyle(fontStyle: FontStyle.italic),
                ),
              ].nullParser(),
            ),
          ),
        ),
        Positioned.fill(
          child: Material(
            type: MaterialType.transparency,
            child: InkWell(
              borderRadius: BorderRadius.circular(8),
              onTap: onTap,
            ),
          ),
        ),
      ],
    );
  }
}

class LilButton extends StatelessWidget {
  const LilButton({
    super.key,
    required this.icon,
    required this.fun,
    this.size,
    this.padding = const EdgeInsets.all(5.0),
    this.margin,
    this.deactivated = false,
    this.selected = true,
    this.backgroundColor,
  });

  final bool selected;
  final Widget icon;
  final Size? size;
  final EdgeInsets padding;
  final EdgeInsets? margin;
  final Function() fun;
  final bool deactivated;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    final color = (selected ? backgroundColor : backgroundColor?.withValues(alpha: 0.3)) ??
        (selected
            ? Theme.of(context).colorScheme.surfaceContainerHighest
            : Theme.of(context).colorScheme.surfaceContainerHigh);
    final borderrad = BorderRadius.circular(12.0);
    final child = selected
        ? icon
        : ColorFiltered(
            colorFilter: ColorFilter.mode(Colors.grey[600]!, BlendMode.modulate),
            child: icon,
          );
    final func = !deactivated ? fun : null;

    if (size != null) {
      return Container(
        height: size?.height,
        width: size?.width,
        margin: margin,
        child: Card.filled(
          color: color,
          child: InkWell(
            borderRadius: borderrad,
            onTap: func,
            child: Padding(
              padding: padding,
              child: child,
            ),
          ),
        ),
      );
    } else {
      return Card.filled(
        margin: margin,
        color: color,
        child: InkWell(
          borderRadius: borderrad,
          onTap: func,
          child: Padding(
            padding: padding,
            child: child,
          ),
        ),
      );
    }
  }
}

class DiffChip extends StatelessWidget {
  const DiffChip({
    super.key,
    required this.label,
    required this.value,
    this.axis,
    this.isPositive = true,
    this.color,
    this.scaleFactor = 0.7,
    this.radius,
    this.backgroundColor,
    this.icon,
    this.size,
    this.iconSize = 18,
  });

  /// label should use onColor to contrast
  final String label;

  final IconData? icon;
  final double? iconSize;

  /// defaults to surfaceContainerHighest of [Theme]
  final Color? backgroundColor;
  final Color? color;

  final String value;

  /// just use up or down else will be equal or [AxisDirection.left] to not show icon
  final AxisDirection? axis;

  /// show green or red color for diff, true = green
  final bool isPositive;

  /// value scaler
  final double scaleFactor;

  final Size? size;

  /// border radius
  /// defaults to [BorderRadius.circular(12.0)]
  final BorderRadius? radius;

  @override
  Widget build(BuildContext context) {
    final lBGColor = backgroundColor ?? Theme.of(context).colorScheme.surfaceContainerHighest;
    final lColor = color ?? Theme.of(context).colorScheme.onSurface;
    final lColorDiff = isPositive
        ? StaticColors.fromBrightness(context).greenVariant
        : StaticColors.fromBrightness(context).redVariant;
    final lsize = size ?? Size(MediaQuery.sizeOf(context).width, 24);
    final Widget? lDiffIcon = switch (axis) {
      AxisDirection.up => Icon(
          Icons.keyboard_double_arrow_up_rounded,
          color: lColorDiff,
          size: iconSize,
        ),
      AxisDirection.down => Icon(
          Icons.keyboard_double_arrow_down_rounded,
          color: lColorDiff,
          size: iconSize,
        ),
      AxisDirection.left => null,
      _ => Icon(Icons.remove, color: lColor, size: iconSize)
    };
    final lRad = radius ?? BorderRadius.circular(6.0);

    final bool advancedMode = context.watch<SettingsProvider>().prefs[PrefsFlags.menuShowAdvanced];

    return Container(
      decoration: BoxDecoration(
        borderRadius: lRad,
      ),
      clipBehavior: Clip.hardEdge,
      constraints: BoxConstraints.loose(lsize),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Flexible(
            child: Container(
              decoration: BoxDecoration(
                color: lBGColor,
              ),
              padding: const EdgeInsets.only(left: 4.0, right: 4.0),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Text.rich(
                    style: const TextStyle(overflow: TextOverflow.ellipsis),
                    textScaler: TextScaler.linear(scaleFactor),
                    TextSpan(
                      style: TextStyle(color: lColor),
                      children: [
                        icon != null
                            ? WidgetSpan(
                                child: Icon(
                                  icon,
                                  size: iconSize,
                                  color: lColor,
                                ),
                              )
                            : null,
                        icon != null
                            ? const TextSpan(
                                text: ' ',
                              )
                            : null,
                        TextSpan(
                          text: label,
                        ),
                      ].nonNulls.toList(),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: lBGColor.withValues(alpha: 0.5),
            ),
            padding: const EdgeInsets.only(left: 4.0, right: 4.0),
            child: Center(
              child: Text.rich(
                textScaler: TextScaler.linear(scaleFactor),
                TextSpan(
                  style: TextStyle(color: lColor),
                  children: [
                    TextSpan(
                      text: value,
                    ),
                    lDiffIcon != null && advancedMode == true
                        ? WidgetSpan(
                            child: lDiffIcon,
                          )
                        : null,
                  ].nonNulls.toList(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
