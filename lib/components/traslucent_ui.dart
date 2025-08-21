import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sagahelper/providers/config_provider.dart';

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

class SystemNavBar extends ConsumerWidget {
  const SystemNavBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final useTranslucent = ref.watch(configProvider.select((p) => p.useTranslucentUi));
    if (useTranslucent) {
      return TranslucentWidget(
        child: Container(
          height: MediaQuery.paddingOf(context).bottom,
          color: Theme.of(context).colorScheme.surfaceContainer.withValues(alpha: 0.5),
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
