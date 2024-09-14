import 'dart:ui';
import 'package:flutter/material.dart';


class TranslucentWidget extends StatelessWidget {
  final Widget child;
  final double sigma;
  const TranslucentWidget({super.key, required this.child, this.sigma = 3});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: sigma, sigmaY: sigma),
        child: child
      ),
    );
  }
}