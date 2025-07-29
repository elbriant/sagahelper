import 'package:flutter/material.dart';

class OpRouteSearchNotFound extends StatelessWidget {
  const OpRouteSearchNotFound({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset('assets/gif/saga_bug.gif', width: 180),
          const SizedBox(height: 12),
          Text(
            'operator not found',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onPrimaryContainer,
              fontWeight: FontWeight.w600,
            ),
            textScaler: const TextScaler.linear(1.2),
          ),
        ],
      ),
    );
  }
}
