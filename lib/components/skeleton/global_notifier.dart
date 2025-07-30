import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sagahelper/providers/settings_provider.dart';

class GlobalNotifier extends StatelessWidget {
  const GlobalNotifier({super.key});

  @override
  Widget build(BuildContext context) {
    final isShowingNotify = context.select<SettingsProvider, bool>((p) => p.showNotifier);
    final notifyString = context.select<SettingsProvider, String>((p) => p.loadingString);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 600),
      curve: Curves.ease,
      padding: EdgeInsets.fromLTRB(
        20,
        MediaQuery.of(context).padding.top + 2.0,
        20,
        2.0,
      ),
      height: isShowingNotify ? (MediaQuery.of(context).padding.top + 24) : 0,
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
              notifyString,
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
