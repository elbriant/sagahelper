import 'dart:async';
import 'dart:convert';
import 'package:flutter/scheduler.dart';
import 'package:sagahelper/components/operator_route/op_route_error.dart';
import 'package:sagahelper/components/operator_route/op_route_filters_popup.dart';
import 'package:sagahelper/components/operator_route/op_route_loading.dart';
import 'package:sagahelper/components/operator_route/op_route_search_not_found.dart';
import 'package:sagahelper/components/operator_info_page/operator_container.dart';
import 'package:sagahelper/core/global_data.dart';
import 'package:sagahelper/models/filters.dart';
import 'package:sagahelper/models/operator.dart';
import 'package:sagahelper/providers/cache_provider.dart';
import 'package:sagahelper/providers/server_provider.dart';
import 'package:sagahelper/providers/settings_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sagahelper/providers/ui_provider.dart';
import 'package:sagahelper/components/traslucent_ui.dart';
import 'package:sagahelper/utils/extensions.dart';

Future<List<Operator>> getOperators() async {
  var cacheProv = NavigationService.navigatorKey.currentContext!.read<CacheProvider>();
  Servers server =
      NavigationService.navigatorKey.currentContext!.read<SettingsProvider>().currentServer;
  String version =
      NavigationService.navigatorKey.currentContext!.read<ServerProvider>().versionOf(server);
  if (cacheProv.operatorsDataCached &&
      server == cacheProv.cachedListOperatorServer &&
      version == cacheProv.cachedListOperatorVersion) {
    return Future<List<Operator>>.value(cacheProv.cachedListOperator);
  }

  final bool checkfiles =
      await NavigationService.navigatorKey.currentContext!.read<ServerProvider>().existFiles(
            NavigationService.navigatorKey.currentContext!.read<SettingsProvider>().currentServer,
            ServerProvider.opFiles,
          );

  if (!checkfiles) throw const FormatException('Update gamedata');

  List<String> response = [];

  for (String filepath in ServerProvider.opFiles) {
    response.add(
      await NavigationService.navigatorKey.currentContext!
          .read<ServerProvider>()
          .getFile(filepath, server),
    );
  }

  List<String> misc = [];

  for (String filepath in ServerProvider.metadataFiles) {
    misc.add(
      await NavigationService.navigatorKey.currentContext!
          .read<ServerProvider>()
          .getFile(filepath, server),
    );
  }

  List<List<String>> input = [response, misc];

  // Use the compute function to run parsing in a separate isolate.
  List<Operator> completedList = await compute(parseOperators, input);

  cacheProv.operatorsDataCache(
    listOperator: completedList,
    listOperatorServer: server,
    listOperatorVersion: version,
    rangeTable: jsonDecode(response[4]) as Map<String, dynamic>,
    skillTable: jsonDecode(response[5]) as Map<String, dynamic>,
    modTable: jsonDecode(response[6]) as Map<String, dynamic>,
    baseSkillTable:
        (jsonDecode(response[7]) as Map<String, dynamic>)["buffs"] as Map<String, dynamic>,
    modStatsTable: jsonDecode(response[8]) as Map<String, dynamic>,
    teamTable: jsonDecode(misc[0]) as Map<String, dynamic>,
    charPatch: jsonDecode(misc[1]) as Map<String, dynamic>,
    charMeta: jsonDecode(misc[2]) as Map<String, dynamic>,
    gamedataConst: jsonDecode(misc[3]) as Map<String, dynamic>,
    charTable: jsonDecode(response[0]) as Map<String, dynamic>,
    gachaTable: jsonDecode(misc[4]) as Map<String, dynamic>,
  );

  return completedList;
}

List<Operator> parseOperators(List<List<String>> input) {
  var operatorsparsed = (jsonDecode(input[0][0]) as Map<String, dynamic>);
  operatorsparsed.addEntries(
    ((jsonDecode(input[1][1]) as Map<String, dynamic>)["patchChars"] as Map<String, dynamic>)
        .entries,
  );
  final loreInfo = jsonDecode(input[0][1]) as Map<String, dynamic>;
  final voiceInfo = jsonDecode(input[0][2]) as Map<String, dynamic>;
  final skinInfo = jsonDecode(input[0][3]) as Map<String, dynamic>;
  final modtable = jsonDecode(input[0][6]) as Map<String, dynamic>;
  final baseSkillInfo =
      (jsonDecode(input[0][7]) as Map<String, dynamic>)["chars"] as Map<String, dynamic>;
  final charPatch = jsonDecode(input[1][1]) as Map<String, dynamic>;

  List<Operator> opsLists = [];
  operatorsparsed.forEach((key, value) {
    if ((value['subProfessionId'] as String).startsWith('notchar') ||
        key.startsWith('trap') ||
        key.startsWith('token') ||
        value['isNotObtainable'] == true) {
    } else {
      opsLists.add(
        Operator.fromJson(
          key,
          value,
          loreInfo['handbookDict'],
          voiceInfo,
          skinInfo['charSkins'],
          baseSkillInfo,
          modtable["charEquip"],
          charPatch,
        ),
      );
    }
  });

  return opsLists;
}

Future<List<Operator>> fetchSafeOperators() {
  return getOperators().then(
    (data) {
      NavigationService.navigatorKey.currentContext!.read<SettingsProvider>().setOpFetched(true);
      return data;
    },
    onError: (e) {
      NavigationService.navigatorKey.currentContext!.read<SettingsProvider>().setOpFetched(true);
      throw e;
    },
  );
}

class OperatorsPage extends StatefulWidget {
  const OperatorsPage({super.key});

  @override
  State<OperatorsPage> createState() => _OperatorsPageState();
}

class _OperatorsPageState extends State<OperatorsPage> {
  final TextEditingController _textController = TextEditingController();
  final MenuController _menuController = MenuController();

  late Future<List<Operator>> futureOperatorList;

  @override
  void initState() {
    super.initState();

    futureOperatorList = fetchSafeOperators();
    SchedulerBinding.instance.addPostFrameCallback((_) {
      precacheImage(const AssetImage('assets/placeholders/avatar.png'), context);
    });
  }

  void reloadgamedata() {
    context.read<CacheProvider>().operatorDataUnCache();
    _menuController.close();
    setState(() {
      futureOperatorList = fetchSafeOperators();
    });
  }

  List<Operator> filteringAndSorting({
    required List<Operator> data,
    required bool isSearching,
    required String searchString,
    required Map<String, FilterDetail> filters,
    required OrderType sortingOrder,
    required bool reverseSorting,
  }) {
    // filter first then sort

    // filtering by text
    if (isSearching && searchString != '') {
      data = data
          .where(
            (op) => op.names.any(
              (name) => name.toLowerCase().contains(searchString.toLowerCase()),
            ),
          )
          .toList();
    }

    // filtering by rarity / class / subclass / etc
    if (filters.isNotEmpty) {
      var whitelist = <FilterType, List<String>>{};
      var blacklist = <FilterType, List<String>>{};

      for (var filter in filters.entries) {
        switch (filter.value.mode) {
          case FilterMode.whitelist:
            whitelist.update(
              filter.value.type,
              (value) {
                value.add(filter.value.key.toLowerCase());
                return value;
              },
              ifAbsent: () => [filter.value.key.toLowerCase()],
            );

          case FilterMode.blacklist:
            blacklist.update(
              filter.value.type,
              (value) {
                value.add(filter.value.key.toLowerCase());
                return value;
              },
              ifAbsent: () => [filter.value.key.toLowerCase()],
            );
        }
      }

      data = data.where((op) {
        bool test = true;

        // whitelist
        // test must evalue true
        for (var rule in whitelist.entries) {
          switch (rule.key) {
            case FilterType.rarity:
              test = rule.value.contains('r${op.rarity.toString()}');

            case FilterType.profession:
              test = rule.value.contains(op.profession.toLowerCase());

            case FilterType.subprofession:
              test = rule.value.contains(op.subProfessionId.toLowerCase());

            case FilterType.faction:
              if (op.factionIds == null) {
                test = false;
              } else {
                test = op.factionIds!.any((element) => rule.value.contains(element.toLowerCase()));
              }
            case FilterType.extra:
              List<String> values = [];
              if (op.modules != null) values.add('has_module');

              test = values.any((e) => rule.value.contains(e.toLowerCase()));
            case FilterType.position:
              test = rule.value.contains(op.position.toLowerCase());
            case FilterType.tag:
              test = op.tagList.any((element) => rule.value.contains(element.toLowerCase()));
          }
          if (test == false) break;
        }

        // blacklist
        // if test evaluate true, return false
        for (var rule in blacklist.entries) {
          switch (rule.key) {
            case FilterType.rarity:
              if (rule.value.contains('r${op.rarity.toString()}')) test = false;

            case FilterType.profession:
              if (rule.value.contains(op.profession.toLowerCase())) test = false;

            case FilterType.subprofession:
              if (rule.value.contains(op.subProfessionId.toLowerCase())) test = false;

            case FilterType.faction:
              if (op.factionIds == null) {
                test = false;
              } else {
                if (op.factionIds!.any((element) => rule.value.contains(element.toLowerCase()))) {
                  test = false;
                }
              }

            case FilterType.extra:
              List<String> values = [];
              if (op.modules != null) values.add('has_module');

              if (values.any((e) => rule.value.contains(e.toLowerCase()))) test = false;
            case FilterType.position:
              if (rule.value.contains(op.position.toLowerCase())) test = false;
            case FilterType.tag:
              if (op.tagList.any((element) => rule.value.contains(element.toLowerCase()))) {
                test = false;
              }
          }
        }

        return test;
      }).toList();
    }

    // sorting
    switch (sortingOrder) {
      case OrderType.rarity:
        data.sort((a, b) {
          int cmp = b.rarity.compareTo(a.rarity);
          if (cmp != 0) return cmp;
          // subsorting is by "creation"
          return int.parse(a.id.split('_')[1]).compareTo(int.parse(b.id.split('_')[1]));
        });

      case OrderType.alphabetical:
        data.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));

      // creation is just take the id number the op has
      case OrderType.creation:
        data.sort(
          (a, b) => int.parse(a.id.split('_')[1]).compareTo(int.parse(b.id.split('_')[1])),
        );
    }

    if (reverseSorting) data = data.reversed.toList();

    return data;
  }

  @override
  Widget build(BuildContext context) {
    final isSearching = context.select<SettingsProvider, bool>((prov) => prov.operatorIsSearching);
    final searchString =
        context.select<SettingsProvider, String>((prov) => prov.operatorFilterString);
    final sortingOrder = context.select<SettingsProvider, OrderType>((prov) => prov.sortingOrder);
    final reverseSorting = context.select<SettingsProvider, bool>((prov) => prov.sortingReversed);
    final opFetched = context.select<SettingsProvider, bool>((prov) => prov.opFetched);
    final currentFilters =
        context.select<SettingsProvider, Map<String, FilterDetail>>((prov) => prov.operatorFilters);
    final isCached = context.watch<CacheProvider>().operatorsDataCached;

    return Scaffold(
      extendBody: false,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: isSearching
            ? TextField(
                autofocus: true,
                textAlignVertical: TextAlignVertical.center,
                controller: _textController,
                decoration: InputDecoration(
                  prefixIcon: IconButton(
                    icon: const Icon(Icons.search_off),
                    onPressed: () {
                      _textController.text = '';
                      context.read<SettingsProvider>().setOperatorFilterString('');
                      context.read<SettingsProvider>().setOperatorIsSearching(false);
                    },
                  ),
                  hintText: 'Search...',
                  border: const UnderlineInputBorder(),
                ),
                onChanged: (value) =>
                    context.read<SettingsProvider>().setOperatorFilterString(value),
                onSubmitted: (value) =>
                    context.read<SettingsProvider>().setOperatorFilterString(value),
              )
            : const Text('Operators'),
        flexibleSpace: context.read<UiProvider>().useTranslucentUi == true
            ? TranslucentWidget(
                sigma: 3,
                child: Container(color: Colors.transparent),
              )
            : null,
        backgroundColor: context.read<UiProvider>().useTranslucentUi == true
            ? Theme.of(context).colorScheme.surfaceContainer.withValues(alpha: 0.5)
            : null,
        actions: [
          !isSearching
              ? IconButton(
                  onPressed: () => context.read<SettingsProvider>().setOperatorIsSearching(true),
                  icon: const Icon(Icons.search),
                  tooltip: 'search operator',
                )
              : null,
          IconButton(
            onPressed: opFetched && isCached ? showFilters : null,
            icon: Icon(
              Icons.filter_list,
              color: currentFilters.isNotEmpty ? Colors.amberAccent[400] : null,
            ),
            tooltip: 'Show filters',
          ),
          MenuAnchor(
            menuChildren: [
              ListTile(
                title: const Text('reload gamedata'),
                onTap: reloadgamedata,
                enabled: opFetched,
              ),
            ],
            controller: _menuController,
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
                icon: const Icon(Icons.more_vert),
                tooltip: 'Show menu',
              );
            },
          ),
        ].nullParser(),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: FutureBuilder<List<Operator>>(
          future: futureOperatorList,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const OpRouteLoading();
            } // loading

            if (snapshot.hasError) return OpRouteError(error: snapshot.error); //  Error

            if (snapshot.hasData) {
              final operatorList = filteringAndSorting(
                data: snapshot.data!,
                filters: currentFilters,
                isSearching: isSearching,
                reverseSorting: reverseSorting,
                searchString: searchString,
                sortingOrder: sortingOrder,
              );

              if (operatorList.isEmpty) {
                return const OpRouteSearchNotFound();
              } else {
                return OperatorListView(operators: operatorList);
              }
            }

            return const OpRouteError(); // just in case
          },
        ),
      ),
    );
  }

  void showFilters() {
    showModalBottomSheet<void>(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      enableDrag: true,
      clipBehavior: Clip.hardEdge,
      isScrollControlled: true,
      context: context,
      builder: (BuildContext context) {
        return const OpRouteFiltersPopup();
      },
    ).whenComplete(() {
      NavigationService.navigatorKey.currentContext!.read<SettingsProvider>().writeOpPageSettings();
    });
  }
}

class OperatorListView extends StatelessWidget {
  final List<Operator> operators;
  const OperatorListView({super.key, required this.operators});

  @override
  Widget build(BuildContext context) {
    final searchDelegate = context.select<SettingsProvider, int>((p) => p.operatorSearchDelegate);
    final opDisplay = context.select<SettingsProvider, DisplayList>((p) => p.operatorDisplay);

    return RawScrollbar(
      thickness: 12,
      interactive: true,
      radius: const Radius.circular(12),
      minThumbLength: 48,
      mainAxisMargin: 4,
      thumbColor: Theme.of(context).colorScheme.secondary.withValues(alpha: 0.8),
      child: GridView.builder(
        itemCount: operators.length,
        addAutomaticKeepAlives: true,
        cacheExtent: (2000 * searchDelegate).toDouble(),
        padding: EdgeInsets.fromLTRB(
          4.0,
          MediaQuery.paddingOf(context).top + 4.0,
          4.0,
          MediaQuery.paddingOf(context).bottom + 4.0,
        ),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: searchDelegate,
          childAspectRatio: opDisplay == DisplayList.portrait ? 0.54 : 1.0,
        ),
        itemBuilder: (context, index) =>
            OperatorContainer(index: index, operator: operators[index]),
      ),
    );
  }
}
