import 'package:flutter/material.dart';

class OpRouteLoading extends StatelessWidget {
  const OpRouteLoading({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      // ----------------- loading
      child: Column(
        children: [
          const LinearProgressIndicator(),
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset(
                    'assets/gif/saga_loading.gif',
                    width: 180,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Loading Operators',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                      fontWeight: FontWeight.w600,
                    ),
                    textScaler: const TextScaler.linear(1.3),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
