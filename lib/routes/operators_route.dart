import 'dart:async';
import 'dart:convert';
import 'package:contentsize_tabbarview/contentsize_tabbarview.dart';
import 'package:expandable/expandable.dart';
import 'package:sagahelper/components/operator_container.dart';
import 'package:sagahelper/global_data.dart';
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

const List<String> professionList = [
  'caster',
  'medic',
  'pioneer',
  'sniper',
  'special',
  'support',
  'tank',
  'warrior',
];

Future<List<Operator>> getOperators() async {
  var cacheProv = NavigationService.navigatorKey.currentContext!.read<CacheProvider>();
  Servers server =
      NavigationService.navigatorKey.currentContext!.read<SettingsProvider>().currentServer;
  String version =
      NavigationService.navigatorKey.currentContext!.read<ServerProvider>().versionOf(server);
  if (cacheProv.isCached) {
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

  cacheProv.cache(
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
    final isCached = context.read<CacheProvider>().isCached;

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
            ? Theme.of(context).colorScheme.surfaceContainer.withOpacity(0.5)
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
            if (snapshot.connectionState != ConnectionState.done) return loadingWidget(); // loading

            if (snapshot.hasError) return errorWidget(snapshot.error); //  Error

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
                return searchOperatorNotFoundWidget();
              } else {
                return OperatorListView(operators: operatorList);
              }
            }

            return errorWidget(null); // just in case
          },
        ),
      ),
    );
  }

  Widget loadingWidget() {
    return SafeArea(
      // ----------------- loading
      child: Column(
        children: [
          const LinearProgressIndicator(),
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset(
                    'assets/gif/saga_loading.gif',
                    width: 180,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Loading Operators',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                      fontWeight: FontWeight.w600,
                    ),
                    textScaler: const TextScaler.linear(1.3),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget errorWidget(Object? error) {
    if (error is FormatException) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset('assets/gif/saga_err.gif', width: 180),
            const SizedBox(height: 12),
            Text(
              error.message,
              style: TextStyle(
                color: Theme.of(context).colorScheme.error,
                fontWeight: FontWeight.w500,
              ),
              textScaler: const TextScaler.linear(1.10),
            ),
          ],
        ),
      );
    } else {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset('assets/gif/saga_err.gif', width: 180),
            const SizedBox(height: 12),
            Text(
              'An unknown error has ocurred!\n ${error?.toString()}',
              style: TextStyle(
                color: Theme.of(context).colorScheme.error,
                fontWeight: FontWeight.w500,
              ),
              textScaler: const TextScaler.linear(1.10),
            ),
          ],
        ),
      );
    }
  }

  Widget searchOperatorNotFoundWidget() {
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
        final currentSortingType =
            context.select<SettingsProvider, OrderType>((prov) => prov.sortingOrder);
        final currentSortingReversed =
            context.select<SettingsProvider, bool>((prov) => prov.sortingReversed);
        final currentSearchDelegate =
            context.select<SettingsProvider, int>((prov) => prov.operatorSearchDelegate);
        final currentSearchDisplay =
            context.select<SettingsProvider, DisplayList>((prov) => prov.operatorDisplay);
        final currentFilters = context
            .select<SettingsProvider, Map<String, FilterDetail>>((prov) => prov.operatorFilters);

        final cacheProv = context.read<CacheProvider>();

        void changeSortingType(OrderType newOrder) {
          if (currentSortingType == newOrder) {
            context.read<SettingsProvider>().setSortingReverse(!currentSortingReversed);
            return;
          }
          context.read<SettingsProvider>().setSortingType(newOrder);
          context.read<SettingsProvider>().setSortingReverse(false);
        }

        Widget orderTypeWidgets({required OrderType orderType, required String label}) {
          return ListTile(
            leading: currentSortingType == orderType
                ? currentSortingReversed
                    ? const Icon(Icons.arrow_upward)
                    : const Icon(Icons.arrow_downward)
                : const Icon(
                    Icons.arrow_downward,
                    color: Colors.transparent,
                  ),
            title: Text(label),
            onTap: () => changeSortingType(orderType),
          );
        }

        List<Widget> professionFilters() {
          return List.generate(professionList.length, (index) {
            final id = 'class_${professionList[index]}';
            return FilterChip(
              label: Text(Operator.professionTranslate(professionList[index].toLowerCase())),
              selected: currentFilters.containsKey(id),
              avatar: currentFilters.containsKey(id)
                  ? Icon(
                      currentFilters[id]!.mode == FilterMode.whitelist ? Icons.check : Icons.block,
                    )
                  : null,
              onSelected: (_) => context
                  .read<SettingsProvider>()
                  .toggleOperatorFilter(id, professionList[index], FilterType.profession),
              showCheckmark: false,
            );
          });
        }

        List<Widget> subProfessionFilters() {
          List<Widget> result = [];

          for (var subclass in (cacheProv.cachedModTable!["subProfDict"] as Map).entries) {
            if ((subclass.key as String).startsWith('notchar') ||
                (subclass.key as String).startsWith('none')) continue;

            final id = 'subclass_${subclass.key}';

            result.add(
              FilterChip(
                label: Text(subclass.value["subProfessionName"]),
                selected: currentFilters.containsKey(id),
                avatar: currentFilters.containsKey(id)
                    ? Icon(
                        currentFilters[id]!.mode == FilterMode.whitelist
                            ? Icons.check
                            : Icons.block,
                      )
                    : null,
                onSelected: (_) => context
                    .read<SettingsProvider>()
                    .toggleOperatorFilter(id, subclass.key, FilterType.subprofession),
                showCheckmark: false,
              ),
            );
          }

          return result;
        }

        List<Widget> rarityFilters() {
          return List.generate(6, (index) {
            final String rarityString = 'r${(index + 1).toString()}';

            return FilterChip(
              label: Text('${(index + 1).toString()} \u2605'),
              selected: currentFilters.containsKey(rarityString),
              avatar: currentFilters.containsKey(rarityString)
                  ? Icon(
                      currentFilters[rarityString]!.mode == FilterMode.whitelist
                          ? Icons.check
                          : Icons.block,
                    )
                  : null,
              onSelected: (_) => context
                  .read<SettingsProvider>()
                  .toggleOperatorFilter(rarityString, rarityString, FilterType.rarity),
              showCheckmark: false,
            );
          });
        }

        List<Widget> factionFilters() {
          List<Widget> result = [];

          for (var faction in (cacheProv.cachedTeamTable as Map).entries) {
            if ((faction.key as String).startsWith('none')) continue;

            final id = 'faction_${faction.key}';

            result.add(
              FilterChip(
                label: Text(faction.value["powerName"]),
                selected: currentFilters.containsKey(id),
                avatar: currentFilters.containsKey(id)
                    ? Icon(
                        currentFilters[id]!.mode == FilterMode.whitelist
                            ? Icons.check
                            : Icons.block,
                      )
                    : null,
                onSelected: (_) => context.read<SettingsProvider>().toggleOperatorFilter(
                      id,
                      (faction.value["powerId"] as String).toLowerCase(),
                      FilterType.faction,
                    ),
                showCheckmark: false,
              ),
            );
          }
          return result;
        }

        List<Widget> extraFilters() {
          List<Widget> result = [
            FilterChip(
              label: const Text('Has module'),
              selected: currentFilters.containsKey('has_module'),
              avatar: currentFilters.containsKey('has_module')
                  ? Icon(
                      currentFilters['has_module']!.mode == FilterMode.whitelist
                          ? Icons.check
                          : Icons.block,
                    )
                  : null,
              onSelected: (_) => context.read<SettingsProvider>().toggleOperatorFilter(
                    'has_module',
                    'has_module',
                    FilterType.extra,
                  ),
              showCheckmark: false,
            ),
          ];

          return result;
        }

        Widget filterTile({required String title, required Widget child}) {
          return ExpandableNotifier(
            child: ScrollOnExpand(
              child: ExpandablePanel(
                theme: ExpandableThemeData(
                  headerAlignment: ExpandablePanelHeaderAlignment.center,
                  iconColor: Theme.of(context).colorScheme.onSurface,
                ),
                header: ListTile(title: Text(title)),
                collapsed: const SizedBox(
                  height: 0,
                ),
                expanded: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  child: child,
                ),
              ),
            ),
          );
        }

        return DefaultTabController(
          initialIndex: 0,
          length: 3,
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const TabBar(
                  tabs: <Widget>[
                    Tab(text: 'Filters'),
                    Tab(text: 'Order'),
                    Tab(text: 'Appareance'),
                  ],
                ),
                ConstrainedBox(
                  constraints: BoxConstraints.loose(
                    Size(
                      MediaQuery.of(context).size.width,
                      MediaQuery.of(context).size.height * 0.65,
                    ),
                  ),
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ContentSizeTabBarView(
                        children: <Widget>[
                          // ----------- filtering
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 10),
                              Center(
                                child: OutlinedButton(
                                  onPressed: currentFilters.isNotEmpty
                                      ? context.read<SettingsProvider>().clearOperatorFilters
                                      : null,
                                  child: const Text('Clear filters'),
                                ),
                              ),
                              filterTile(
                                title: 'Rarity',
                                child: Wrap(
                                  spacing: 6.0,
                                  children: rarityFilters(),
                                ),
                              ),
                              filterTile(
                                title: 'Classes',
                                child: Wrap(
                                  spacing: 6.0,
                                  children: professionFilters(),
                                ),
                              ),
                              filterTile(
                                title: 'Subclasses',
                                child: Wrap(
                                  spacing: 6.0,
                                  children: subProfessionFilters(),
                                ),
                              ),
                              filterTile(
                                title: 'Faction',
                                child: Wrap(
                                  spacing: 6.0,
                                  children: factionFilters(),
                                ),
                              ),
                              filterTile(
                                title: 'Extras',
                                child: Wrap(
                                  spacing: 6.0,
                                  children: extraFilters(),
                                ),
                              ),
                            ],
                          ),

                          // ----------- order sorting

                          Wrap(
                            children: [
                              orderTypeWidgets(
                                label: 'Rarity',
                                orderType: OrderType.rarity,
                              ),
                              orderTypeWidgets(
                                label: 'Alphabetical',
                                orderType: OrderType.alphabetical,
                              ),
                              orderTypeWidgets(
                                label: 'Creation',
                                orderType: OrderType.creation,
                              ),
                            ],
                          ),

                          // ----------- Appareance
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const ListTile(title: Text('Cards')),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24.0,
                                ),
                                child: Wrap(
                                  spacing: 10,
                                  children: [
                                    ChoiceChip(
                                      label: const Text('Avatar'),
                                      selected: currentSearchDisplay == DisplayList.avatar,
                                      onSelected: (_) => context
                                          .read<SettingsProvider>()
                                          .setDisplayChip(DisplayList.avatar),
                                    ),
                                    ChoiceChip(
                                      label: const Text('Portrait'),
                                      selected: currentSearchDisplay == DisplayList.portrait,
                                      onSelected: (_) => context
                                          .read<SettingsProvider>()
                                          .setDisplayChip(DisplayList.portrait),
                                    ),
                                  ],
                                ),
                              ),
                              Row(
                                mainAxisSize: MainAxisSize.max,
                                children: [
                                  const Expanded(
                                    flex: 3,
                                    child: Center(child: Text('Cards per row')),
                                  ),
                                  Expanded(
                                    flex: 7,
                                    child: Center(
                                      child: Slider(
                                        min: 2,
                                        max: 5,
                                        divisions: 3,
                                        value: currentSearchDelegate.toDouble(),
                                        label: currentSearchDelegate.toString(),
                                        onChanged: (value) {
                                          context.read<SettingsProvider>().operatorSearchDelegate =
                                              value.round().toInt();
                                        },
                                        allowedInteraction: SliderInteraction.tapAndSlide,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    ).whenComplete(() {
      NavigationService.navigatorKey.currentContext!.read<SettingsProvider>().writeOpPageSettings();
    });
  }

  void reloadgamedata() {
    context.read<CacheProvider>().unCache();
    _menuController.close();
    NavigationService.navigatorKey.currentContext!.read<SettingsProvider>().setOpFetched(false);
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
          }
          if (test == false) break;
        }

        // blacklist
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
}

class OperatorListView extends StatelessWidget {
  final List<Operator> operators;
  const OperatorListView({super.key, required this.operators});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();

    return RawScrollbar(
      thickness: 12,
      interactive: true,
      radius: const Radius.circular(12),
      minThumbLength: 48,
      mainAxisMargin: 4,
      thumbColor: Theme.of(context).colorScheme.secondary.withOpacity(0.8),
      child: GridView(
        cacheExtent: 1500,
        padding: EdgeInsets.fromLTRB(
          4.0,
          MediaQuery.paddingOf(context).top + 4.0,
          4.0,
          MediaQuery.paddingOf(context).bottom + 4.0,
        ),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: settings.operatorSearchDelegate,
          childAspectRatio: settings.operatorDisplay == DisplayList.portrait ? 0.55 : 1.0,
        ),
        children: List.generate(
          operators.length,
          (int index) => OperatorContainer(index: index, operator: operators[index]),
        ),
      ),
    );
  }
}
