import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sagahelper/providers/tasker_provider.dart';

const randomWords = ['Natto gohan...', 'Aburage...', 'Completed...', 'Working...'];

// TODO: add global notifier to nagvigator pushes

class GlobalNotifier extends ConsumerWidget {
  const GlobalNotifier({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasker = ref.watch(taskerProvider);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 600),
      curve: Curves.ease,
      padding: EdgeInsets.fromLTRB(
        20,
        MediaQuery.of(context).padding.top + 2.0,
        20,
        2.0,
      ),
      height: tasker.isActive ? (MediaQuery.of(context).padding.top + 24) : 0,
      color: Theme.of(context).colorScheme.primary,
      constraints: BoxConstraints.loose(MediaQuery.sizeOf(context)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            height: 12,
            width: 12,
            child: CircularProgressIndicator(
              color: Theme.of(context).colorScheme.onPrimary,
              strokeWidth: 3.0,
            ),
          ),
          const SizedBox(width: 20),
          Flexible(
            child: Text(
              tasker.taskQueue.lastOrNull?.message ??
                  randomWords[Random().nextInt(randomWords.length)],
              style: TextStyle(
                color: Theme.of(context).colorScheme.onPrimary,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
