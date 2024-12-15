import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sagahelper/providers/ui_provider.dart';

class TranslucentWidget extends StatelessWidget {
  final Widget child;
  final double sigma;
  const TranslucentWidget({super.key, required this.child, this.sigma = 3});

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: sigma, sigmaY: sigma),
        blendMode: BlendMode.src,
        child: child,
      ),
    );
  }
}

class SystemNavBar extends StatelessWidget {
  const SystemNavBar({super.key});

  @override
  Widget build(BuildContext context) {
    if (context.read<UiProvider>().useTranslucentUi) {
      return TranslucentWidget(
        child: Container(
          height: MediaQuery.paddingOf(context).bottom,
          color: Theme.of(context).colorScheme.surfaceContainer.withOpacity(0.5),
        ),
      );
    } else {
      return Container(
        height: MediaQuery.paddingOf(context).bottom,
        color: Theme.of(context).colorScheme.surfaceContainer,
      );
    }
  }
}
