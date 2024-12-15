import 'package:sagahelper/components/custom_tabbar.dart';
import 'package:sagahelper/models/operator.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sagahelper/pages/opinfo_archive_page.dart';
import 'package:sagahelper/pages/opinfo_art_page.dart';
import 'package:sagahelper/pages/opinfo_voice_page.dart';
import 'package:sagahelper/providers/ui_provider.dart';

class OperatorInfo extends StatefulWidget {
  final Operator operator;
  const OperatorInfo(this.operator, {super.key});

  @override
  State<OperatorInfo> createState() => _OperatorInfoState();
}

class _OperatorInfoState extends State<OperatorInfo> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Tab> tabs = <Tab>[
    const Tab(text: 'Archive', icon: Icon(Icons.file_present)),
    const Tab(text: 'Art', icon: Icon(Icons.filter)),
    const Tab(text: 'Voice', icon: Icon(Icons.voice_chat)),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(vsync: this, length: tabs.length);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: TabBarView(
        controller: _tabController,
        physics: const NeverScrollableScrollPhysics(),
        children: <Widget>[
          ArchivePage(widget.operator),
          ArtPage(widget.operator),
          VoicePage(widget.operator),
        ],
      ),
      bottomNavigationBar: context.read<UiProvider>().useTranslucentUi
          ? CustomTabBar(
              controller: _tabController,
              tabs: tabs,
              isTransparent: true,
            )
          : CustomTabBar(controller: _tabController, tabs: tabs),
    );
  }
}
