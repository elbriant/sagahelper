import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sagahelper/components/traslucent_ui.dart';
import 'package:sagahelper/providers/config_provider.dart';

class TranslucentAppBar extends ConsumerWidget implements PreferredSizeWidget {
  const TranslucentAppBar({required this.title, required this.preferredSize, super.key});

  @override
  final Size preferredSize;

  final Widget title;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final translucentUi = ref.watch(configProvider.select((p) => p.useTranslucentUi));

    return AppBar(
      title: title,
      flexibleSpace: translucentUi
          ? TranslucentWidget(
              sigma: 3,
              child: Container(color: Colors.transparent),
            )
          : null,
      backgroundColor: translucentUi
          ? Theme.of(context).colorScheme.surfaceContainer.withValues(alpha: 0.5)
          : null,
      elevation: 0,
    );
  }
}
