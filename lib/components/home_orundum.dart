import 'package:flutter/material.dart';
import 'package:glass_kit/glass_kit.dart';

class HomeOrundum extends StatelessWidget {
  const HomeOrundum({super.key, required this.orundumResetTime});

  final String orundumResetTime;

  @override
  Widget build(BuildContext context) {
    return GlassContainer.clearGlass(
      height: 120,
      borderRadius: BorderRadius.circular(12),
      padding: const EdgeInsets.all(2.0),
      gradient: LinearGradient(
        colors: [
          Theme.of(context).colorScheme.tertiaryContainer.withOpacity(0.40),
          Theme.of(context).colorScheme.tertiaryContainer.withOpacity(0.10),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderGradient: LinearGradient(
        colors: [
          const Color(0xffff0000),
          Theme.of(context).colorScheme.primary.withOpacity(0.40),
        ],
        stops: const [0.25, 0.75],
        begin: Alignment.bottomLeft,
        end: Alignment.topRight,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          children: [
            Image.asset(
              'assets/orundum.webp',
              scale: 1.8,
              fit: BoxFit.none,
              width: double.maxFinite,
              alignment: const Alignment(-0.8, 0.2),
              colorBlendMode: BlendMode.modulate,
              color: Colors.white.withOpacity(0.7),
            ),
            Container(
              width: double.maxFinite,
              height: double.maxFinite,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(context).colorScheme.surface.withOpacity(0.4),
                    spreadRadius: -20,
                    blurStyle: BlurStyle.normal,
                    blurRadius: 25,
                  ),
                ],
              ),
              child: Text(
                'Time until weekly orundum reset: \n$orundumResetTime',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
