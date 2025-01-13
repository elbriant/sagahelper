import 'package:flutter/material.dart';

class TraitCard extends StatelessWidget {
  final Text label;
  final Widget content;
  final ImageProvider avatar;
  const TraitCard({super.key, required this.label, required this.content, required this.avatar});

  @override
  Widget build(BuildContext context) {
    return Card.filled(
      margin: const EdgeInsets.only(top: 6.0, bottom: 18.0),
      elevation: 1.0,
      child: Container(
        width: double.maxFinite,
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                Container(
                  margin: const EdgeInsets.only(bottom: 12.0, top: 8.0),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Theme.of(context).colorScheme.outline,
                    ),
                  ),
                  padding: const EdgeInsets.only(
                    top: 2.0,
                    bottom: 2.0,
                    right: 12.0,
                    left: 42,
                  ),
                  child: label,
                ),
                Positioned(
                  left: 0,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: HSLColor.fromColor(Theme.of(context).colorScheme.primary)
                          .withLightness(0.10)
                          .toColor(),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Theme.of(context).colorScheme.outline,
                      ),
                    ),
                    child: SizedBox.square(
                      dimension: 40,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Image(
                          image: avatar,
                          fit: BoxFit.scaleDown,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            content,
          ],
        ),
      ),
    );
  }
}
