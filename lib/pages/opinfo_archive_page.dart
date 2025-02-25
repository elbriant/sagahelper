import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sagahelper/components/operator_lil_card.dart';
import 'package:sagahelper/components/opinfo_archive_header.dart';
import 'package:sagahelper/components/opinfo_archive_lore.dart';
import 'package:sagahelper/components/opinfo_archive_skill.dart';
import 'package:sagahelper/components/traslucent_ui.dart';
import 'package:sagahelper/global_data.dart';
import 'package:sagahelper/models/operator.dart';
import 'package:sagahelper/providers/settings_provider.dart';
import 'package:sagahelper/providers/cache_provider.dart';
import 'package:sagahelper/providers/ui_provider.dart';

class ArchivePage extends StatefulWidget {
  final Operator operator;
  const ArchivePage(this.operator, {super.key});

  @override
  State<ArchivePage> createState() => _ArchivePageState();
}

List<Operator>? computingRelatedOps(List input) {
  List<Operator>? result;
  List<dynamic>? opGroup; // List<String>

  if (input[4]) {
    for (Map group in (input[3]["infos"] as Map<String, dynamic>).values) {
      if ((group["tmplIds"] as List).contains(input[0])) {
        opGroup = group["tmplIds"];
        break;
      }
    }
  } else {
    for (List group in (input[1]["spCharGroups"] as Map<String, dynamic>).values) {
      if (group.contains(input[0])) {
        opGroup = group;
        break;
      }
    }
  }
  if (opGroup == null || opGroup.length <= 1) return result;

  result = [];

  for (final opId in opGroup) {
    if (opId == input[0]) continue;

    final relOp = (input[2] as List<Operator>).singleWhere((element) => element.id == opId);

    result.add(relOp);
  }

  return result;
}

class _ArchivePageState extends State<ArchivePage>
    with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  late TabController _secondaryTabController;
  final List<Tab> _secTabs = <Tab>[
    const Tab(text: 'Combat'),
    const Tab(text: 'File'),
  ];

  late final List<Widget> secChildren;

  late Future<List<Operator>?> relatedOperatorList;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();

    relatedOperatorList = getRelatedOps();

    _secondaryTabController = TabController(vsync: this, length: _secTabs.length)
      ..addListener(() {
        setState(() {
          // change tab
        });
      });

    secChildren = [
      OpinfoArchiveSkill(widget.operator),
      OpinfoArchiveLore(widget.operator),
    ];
  }

  Future<List<Operator>?> getRelatedOps() async {
    final charMeta =
        NavigationService.navigatorKey.currentContext!.read<CacheProvider>().cachedCharMeta;
    final charPatch =
        NavigationService.navigatorKey.currentContext!.read<CacheProvider>().cachedCharPatch;
    final opList =
        NavigationService.navigatorKey.currentContext!.read<CacheProvider>().cachedListOperator;
    final bool opHasPatch = widget.operator.opPatched;

    final List input = [widget.operator.id, charMeta, opList, charPatch, opHasPatch];

    return await compute(computingRelatedOps, input);
  }

  @override
  void dispose() {
    _secondaryTabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return FutureBuilder(
      future: relatedOperatorList,
      builder: (context, snapshot) {
        if (snapshot.hasError) throw snapshot.error!; //  Error

        Widget relatedOperatorHeader = (snapshot.hasData)
            ? SizedBox(
                width: double.maxFinite,
                child: Padding(
                  padding: const EdgeInsets.only(top: 16.0),
                  child: Column(
                    children: [
                      Text(
                        'Related Operators: ',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          fontSize: 18,
                          fontWeight: ui.FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8.0),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: List.generate(
                            snapshot.data!.length,
                            (index) => OperatorLilCard(operator: snapshot.data![index]),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              )
            : const SizedBox(
                height: 0,
                width: double.maxFinite,
              );

        return CustomScrollView(
          slivers: [
            SliverAppBar.medium(
              flexibleSpace: context.read<UiProvider>().useTranslucentUi == true
                  ? TranslucentWidget(
                      child: FlexibleSpaceBar(
                        title: Text(widget.operator.name),
                        titlePadding: const EdgeInsets.only(
                          left: 72.0,
                          bottom: 16.0,
                          right: 32.0,
                        ),
                      ),
                    )
                  : FlexibleSpaceBar(
                      title: Text(widget.operator.name),
                      titlePadding: const EdgeInsets.only(
                        left: 72.0,
                        bottom: 16.0,
                        right: 32.0,
                      ),
                    ),
              backgroundColor: context.read<UiProvider>().useTranslucentUi == true
                  ? Theme.of(context).colorScheme.surfaceContainer.withOpacity(0.5)
                  : null,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Navigator.pop(context),
              ),
              actions: [
                MenuAnchor(
                  menuChildren: [
                    SwitchListTile(
                      value: context.watch<SettingsProvider>().prefs[PrefsFlags.menuShowAdvanced],
                      onChanged: (bool value) {
                        context
                            .read<SettingsProvider>()
                            .setAndSaveBoolPref(PrefsFlags.menuShowAdvanced, value);
                      },
                      title: const Text('Show advanced'),
                    ),
                  ],
                  builder: (
                    BuildContext context,
                    MenuController controller,
                    Widget? child,
                  ) {
                    return IconButton(
                      onPressed: () {
                        if (controller.isOpen) {
                          controller.close();
                        } else {
                          controller.open();
                        }
                      },
                      icon: const Icon(Icons.more_horiz),
                    );
                  },
                ),
              ],
            ),
            SliverList.list(
              children: [
                OpinfoArchiveHeader(
                  operator: widget.operator,
                  relatedOps: relatedOperatorHeader,
                ),
                TabBar.secondary(
                  controller: _secondaryTabController,
                  indicatorSize: TabBarIndicatorSize.tab,
                  tabs: _secTabs,
                ),
                const SizedBox(height: 20),
              ],
            ),
            SliverToBoxAdapter(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 350),
                child: secChildren[_secondaryTabController.index],
              ),
            ),
            SliverToBoxAdapter(
              child: SizedBox(height: MediaQuery.of(context).padding.bottom),
            ),
          ],
        );
      },
    );
  }
}
