import 'package:sagahelper/components/traslucent_ui.dart';
import 'package:flutter/material.dart';

class CustomTabBar extends StatelessWidget implements PreferredSizeWidget {
  final TabController controller;
  final List<Tab> tabs;
  final bool isTransparent;
  const CustomTabBar({super.key, required this.controller, required this.tabs, this.isTransparent = false});

  @override
  Size get preferredSize => TabBar(tabs: tabs).preferredSize;

  @override
  Widget build(BuildContext context) {
    if (isTransparent) {
      return TranslucentWidget(
        child: Container(
          color: Theme.of(context).colorScheme.surfaceContainer.withOpacity(0.5),
          child: Material(
            type: MaterialType.transparency,
            child: TabBar(
              controller: controller,
              dividerColor: Colors.transparent,
              tabs: tabs,
            ),
          ),
        ),
      );
    } else {
      return Container(
        color: Theme.of(context).colorScheme.surfaceContainer,
        child: Material(
          type: MaterialType.transparency,
          child: TabBar(
            controller: controller,
            dividerColor: Colors.transparent,
            tabs: tabs,
          ),
        ),
      );
    }
  }
}