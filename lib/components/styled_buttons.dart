import 'package:flutter/material.dart';

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
    Size sizing = size ?? Size.square(80);

    return Container(
      constraints: BoxConstraints.loose(sizing),
      child: InkWell(
        onTap: onTap,
        customBorder: CircleBorder(),
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