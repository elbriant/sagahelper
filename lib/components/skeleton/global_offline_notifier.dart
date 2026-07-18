import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sagahelper/providers/connectivity_provider.dart';
import 'package:sagahelper/providers/config_provider.dart';
import 'package:sagahelper/utils/random_face_generator.dart';

class GlobalOfflineNotifier extends ConsumerWidget {
  const GlobalOfflineNotifier({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isConnected = ref.watch(isConnectedProvider);
    final offlineMode = ref.watch(configProvider.select((p) => p.offlineMode));

    final bool showBanner = !isConnected || offlineMode;
    final String face = offlineMode
        ? RandomFaceGenerator.surpriseFace()
        : RandomFaceGenerator.sadFace();
    final String text = offlineMode
        ? 'Offline mode enabled'
        : 'No internet connection';

    return AnimatedContainer(
      duration: const Duration(milliseconds: 600),
      curve: Curves.ease,
      padding: EdgeInsets.fromLTRB(
        20,
        MediaQuery.of(context).padding.top + 2.0,
        20,
        2.0,
      ),
      height: showBanner ? (MediaQuery.of(context).padding.top + 24) : 0,
      color: Colors.grey[800],
      constraints: BoxConstraints.loose(MediaQuery.sizeOf(context)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.wifi_off_rounded,
            color: Colors.grey[300],
            size: 16,
          ),
          const SizedBox(width: 12),
          Text(
            '$text $face',
            style: TextStyle(
              color: Colors.grey[200],
            ),
          ),
        ],
      ),
    );
  }
}
