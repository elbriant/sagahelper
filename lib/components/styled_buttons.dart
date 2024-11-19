import 'package:flutter/material.dart';
import 'package:sagahelper/components/utils.dart' show ListExtension;

class IconButtonStyled extends StatelessWidget {
  const IconButtonStyled({super.key, required this.icon, required this.label, required this.onTap, this.iconFilled, this.selected = false, this.size, this.textStyle});
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
                color: selected == true ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.outline,
                size: sizing.width/3,
              ),
              Text(label, style: textStyle ?? TextStyle(fontSize: sizing.width/7, color: selected == true ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.outline), textAlign: TextAlign.center)
            ],
          ),
        ),
      ),  
    );
  }
}

class StyledLangButton extends StatelessWidget {
  const StyledLangButton({super.key, required this.label, this.sublabel, required this.vaName, required this.onTap, this.selected = false});
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
            color: selected? Color.lerp(Theme.of(context).colorScheme.surfaceContainerHigh, Theme.of(context).colorScheme.secondaryContainer, 0.05) : Theme.of(context).colorScheme.surfaceContainerHigh,
            border: selected? Border.all(color: Theme.of(context).colorScheme.primary) : Border.all(color: Theme.of(context).colorScheme.surfaceContainer),
          ),
          child: Padding(
            padding: const EdgeInsets.all(4.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget?>[
                Text(label, textScaler: const TextScaler.linear(1.5), style: selected? TextStyle(color: Theme.of(context).colorScheme.primary) : null,),
                sublabel != null ? Text(sublabel!, style: selected? TextStyle(color: Theme.of(context).colorScheme.primary.withOpacity(0.7)) : TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7)), textScaler: const TextScaler.linear(0.7)) : null,
                const SizedBox(height: 3),
                Text(vaName, style: const TextStyle(fontStyle: FontStyle.italic),)
              ].nullParser(),
            ),
          ),
        ),
        Positioned.fill(
          child: Material(
            type: MaterialType.transparency,
            child: InkWell(
              borderRadius: BorderRadius.circular(8),
              onTap: onTap
            ),
          ),
        )
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
    this.padding,
    this.margin,
    this.deactivated = false,
    this.selected = true,
  });

  final bool selected;
  final Widget icon;
  final Size? size;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final Function() fun;
  final bool deactivated;

  @override
  Widget build(BuildContext context) {
    if (size != null || padding != null) {
      return Container(
        height: size?.height,
        width: size?.width,
        margin: margin,
        child: Card.filled(
          color: selected ? Theme.of(context).colorScheme.surfaceContainerHighest : Theme.of(context).colorScheme.surfaceContainerHigh,
          child: InkWell(
            borderRadius: BorderRadius.circular(12.0),
            onTap: !deactivated ? fun : null,
            child: Padding(
              padding: padding ?? const EdgeInsets.all(8.0),
              child: selected ? icon : ColorFiltered(colorFilter: ColorFilter.mode(Colors.grey[600]!, BlendMode.modulate), child: icon),
            ),
          ),
        ),
      );
    } else {
      return Card.filled(
        margin: margin,
        color: selected ? Theme.of(context).colorScheme.surfaceContainerHighest : Theme.of(context).colorScheme.surfaceContainerHigh,
        child: InkWell(
          borderRadius: BorderRadius.circular(12.0),
          onTap: !deactivated ? fun : null,
          child: Padding(
            padding: const EdgeInsets.all(5.0),
            child: selected ? icon : ColorFiltered(colorFilter: ColorFilter.mode(Colors.grey[600]!, BlendMode.modulate), child: icon),
          ),
        ),
      );
    }
  }
}