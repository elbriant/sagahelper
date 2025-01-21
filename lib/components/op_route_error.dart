import 'package:flutter/material.dart';

class OpRouteError extends StatelessWidget {
  final Object? error;
  const OpRouteError({super.key, this.error});

  @override
  Widget build(BuildContext context) {
    if (error != null && error is FormatException) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset('assets/gif/saga_err.gif', width: 180),
            const SizedBox(height: 12),
            Text(
              (error as FormatException).message,
              style: TextStyle(
                color: Theme.of(context).colorScheme.error,
                fontWeight: FontWeight.w500,
              ),
              textScaler: const TextScaler.linear(1.10),
            ),
          ],
        ),
      );
    } else {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset('assets/gif/saga_err.gif', width: 180),
            const SizedBox(height: 12),
            Text(
              'An unknown error has ocurred!\n ${error?.toString()}',
              style: TextStyle(
                color: Theme.of(context).colorScheme.error,
                fontWeight: FontWeight.w500,
              ),
              textScaler: const TextScaler.linear(1.10),
            ),
          ],
        ),
      );
    }
  }
}
