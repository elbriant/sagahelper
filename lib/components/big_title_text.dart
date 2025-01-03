import 'package:flutter/material.dart';

class BigTitleText extends StatelessWidget {
  final String title;
  const BigTitleText({
    super.key,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Text(
        title,
        style: TextStyle(
          color: Colors.white,
          shadows: [
            Shadow(blurRadius: 8.0, color: Theme.of(context).colorScheme.secondary),
            Shadow(blurRadius: 32.0, color: Theme.of(context).colorScheme.secondary),
          ],
          fontWeight: FontWeight.w900,
          fontSize: 36,
        ),
        textAlign: TextAlign.start,
      ),
    );
  }
}
