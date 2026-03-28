import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:marquee/marquee.dart';
import 'package:sagahelper/providers/tasker_provider.dart';
import 'package:sagahelper/utils/extensions.dart';

const randomWords = ['Natto gohan...', 'Aburage...', 'Completed...', 'Working...'];

class GlobalNotifier extends ConsumerWidget {
  const GlobalNotifier({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasker = ref.watch(taskerProvider);

    final text = tasker.taskQueue.length > 1
        ? 'Completing ${tasker.taskQueue.length} tasks (${tasker.taskQueue.lastOrNull?.message ?? randomWords[Random().nextInt(randomWords.length)]})'
        : tasker.taskQueue.lastOrNull?.message ?? randomWords[Random().nextInt(randomWords.length)];

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
          ConstrainedBox(
            constraints:
                BoxConstraints.loose(Size(MediaQuery.widthOf(context) * 0.7, double.maxFinite)),
            child: context.measureTextSize(text, const TextStyle()).width >
                    MediaQuery.widthOf(context) * 0.7
                ? Marquee(
                    text: text,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onPrimary,
                    ),
                    velocity: 25,
                    blankSpace: 45.0,
                    startPadding: 45.0,
                    fadingEdgeEndFraction: 0.1,
                    fadingEdgeStartFraction: 0.1,
                    showFadingOnlyWhenScrolling: false,
                    pauseAfterRound: const Duration(seconds: 2),
                  )
                : Text(
                    text,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onPrimary,
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
