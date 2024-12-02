import 'dart:async';
import 'dart:convert';
import 'package:sagahelper/components/operator_container.dart';
import 'package:sagahelper/global_data.dart';
import 'package:sagahelper/models/operator.dart';
import 'package:sagahelper/providers/cache_provider.dart';
import 'package:sagahelper/providers/server_provider.dart';
import 'package:sagahelper/providers/settings_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:autoscale_tabbarview/autoscale_tabbarview.dart';
import 'package:provider/provider.dart';
import 'package:sagahelper/providers/ui_provider.dart';
import 'package:sagahelper/components/traslucent_ui.dart';

const List<String> professionList = ['caster', 'medic', 'pioneer', 'sniper', 'special', 'support', 'tank', 'warrior'];

//TODO complete this for filters
const List<String> subProfessionList = ['agent', 'alchemist', 'aoesniper', 'artsfghter', 'artsprotector', 'bard', 'bearer', 'blastcaster', 'blessing', 'bombarder', 'centurion', 'chain', 'chainhealer', 'charger', ''];

Future<List<Operator>> fetchOperators() async {
  var cacheProv = NavigationService.navigatorKey.currentContext!.read<CacheProvider>();
  String server = NavigationService.navigatorKey.currentContext!.read<SettingsProvider>().currentServerString;
  String version = NavigationService.navigatorKey.currentContext!.read<ServerProvider>().versionOf(server);
  if (cacheProv.isCached) return Future<List<Operator>>.value(cacheProv.cachedListOperator);

  List<String> files = [
    '/excel/character_table.json',
    '/excel/handbook_info_table.json',
    '/excel/charword_table.json',
    '/excel/skin_table.json',
    '/excel/range_table.json',
    '/excel/skill_table.json'
  ];
  // 0 operators
  // 1 lore
  // 2 voice
  // 3 skin
  // 4 ranges
  // 5 skills details

  try {
    await NavigationService.navigatorKey.currentContext!.read<ServerProvider>().existFiles(NavigationService.navigatorKey.currentContext!.read<SettingsProvider>().currentServerString, files);
  } catch (e) {
    throw const FormatException('Update gamedata');
  }

  List<String> response = [];

  for (String filepath in files) {
    response.add(await NavigationService.navigatorKey.currentContext!.read<ServerProvider>().getFile(filepath, server));
  }

  // Use the compute function to run parsing in a separate isolate.
  List<Operator> completedList = await compute(parseOperators, response);

  cacheProv.cachedListOperatorServer = server;
  cacheProv.cachedListOperator = completedList;
  cacheProv.cachedListOperatorVersion = version;
  cacheProv.cachedRangeTable = jsonDecode(response[4]) as Map<String, dynamic>;
  cacheProv.cachedSkillTable = jsonDecode(response[5]) as Map<String, dynamic>;

  return completedList;
  
}

List<Operator> parseOperators(List<String> response) {
  final operatorsparsed = jsonDecode(response[0]) as Map<String, dynamic>;
  final loreInfo = jsonDecode(response[1]) as Map<String, dynamic>;
  final voiceInfo = jsonDecode(response[2]) as Map<String, dynamic>;
  final skinInfo = jsonDecode(response[3]) as Map<String, dynamic>;

  List<Operator> opsLists = [];
  operatorsparsed.forEach((key, value) {
    if (
      (value['subProfessionId'] as String).startsWith('notchar') ||
      key.startsWith('trap') ||
      key.startsWith('token') ||
      value['isNotObtainable'] == true) {
    } else {
      opsLists.add(Operator.fromJson(key, value, loreInfo['handbookDict'], voiceInfo, skinInfo['charSkins']));
    }
  });
  
  return opsLists;
}

class OperatorsPage extends StatefulWidget {
  const OperatorsPage({super.key});

  @override
  State<OperatorsPage> createState() => _OperatorsPageState();
}

class _OperatorsPageState extends State<OperatorsPage> {
  final TextEditingController _textController = TextEditingController();

  late Future<List<Operator>> futureOperatorList;
  List<Operator> finishedFutureOperatorList = [];
  List<Operator> sortedOperatorList = [];
  List<Operator> filteredOperatorList = [];

  bool isSearching = false;
  bool sorted = false;
  String searchString = '';

  @override
  void initState() {
    super.initState();
    futureOperatorList = fetchOperators();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: false,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: isSearching ? TextField(
          autofocus: true,
          textAlignVertical: TextAlignVertical.center,
          controller: _textController,
          decoration: InputDecoration(
            prefixIcon: IconButton(
                icon: const Icon(Icons.search_off), 
                onPressed: () {
                  _textController.text = "";
                  filterOperatorListByText("");
                  setState(() {
                    isSearching = false;
                  });
                }),
            hintText: 'Search...',
            border: const UnderlineInputBorder(),
          ),
          onChanged: (value) => filterOperatorListByText(value),
          onSubmitted: (value) => filterOperatorListByText(value),
        ) : const Text('Operators'),
        flexibleSpace: context.read<UiProvider>().useTranslucentUi == true ? TranslucentWidget(sigma: 3,child: Container(color: Colors.transparent)) : null,
        backgroundColor: context.read<UiProvider>().useTranslucentUi == true ? Theme.of(context).colorScheme.surfaceContainer.withOpacity(0.5) : null,
        actions: [
          isSearching ? Container() : IconButton(onPressed: () => setState((){isSearching = true;}), icon: const Icon(Icons.search)),
          IconButton(onPressed: () => showFilters(context), icon: const Icon(Icons.filter_list)),
          MenuAnchor(
              menuChildren: const [],
              builder: (BuildContext context, MenuController controller,
                  Widget? child) {
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
              }),
        ],
      ),
      body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: FutureBuilder<List<Operator>>(
            future: futureOperatorList,
            builder: (context, snapshot) {
              if (snapshot.hasError) {  // --------------- Error
                if (snapshot.error is FormatException) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Image.asset('assets/gif/saga_err.gif', width: 180),
                        const SizedBox(height: 12),
                        Text((snapshot.error as FormatException).message, style: TextStyle(color: Theme.of(context).colorScheme.error, fontWeight: FontWeight.w500), textScaler: const TextScaler.linear(1.10),)
                      ],
                    )
                  );
                } else {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Image.asset('assets/gif/saga_err.gif', width: 180),
                        const SizedBox(height: 12),
                        Text('An unknown error has ocurred!\n${snapshot.error}', style: TextStyle(color: Theme.of(context).colorScheme.error, fontWeight: FontWeight.w500), textScaler: const TextScaler.linear(1.10),)
                      ],
                    )
                  );
                }
              } else if (snapshot.hasData) {
                finishedFutureOperatorList = snapshot.data!;

                if (!sorted) {
                  // sorting
                  // by letters
                  //finishedFutureOperatorList.sort((a,b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
                  // by rarity
                  finishedFutureOperatorList.sort((a,b) => a.rarity.compareTo(b.rarity));
                  finishedFutureOperatorList = finishedFutureOperatorList.reversed.toList();

                  sortedOperatorList = finishedFutureOperatorList;
                  sorted = true;
                }
                if (isSearching && filteredOperatorList.isEmpty) {
                  if (searchString == '') {
                    return OperatorListView(operators: sortedOperatorList);
                  } else {
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Image.asset('assets/gif/saga_bug.gif', width: 180),
                          const SizedBox(height: 12),
                          Text('operator not found', style: TextStyle(color: Theme.of(context).colorScheme.onPrimaryContainer, fontWeight: FontWeight.w600), textScaler: const TextScaler.linear(1.2),)
                        ],
                      )
                    );
                  }
                } else if (isSearching && filteredOperatorList.isNotEmpty) {
                  return OperatorListView(operators: filteredOperatorList);
                } else {
                  return OperatorListView(operators: sortedOperatorList);
                }
              } else {
                return SafeArea( // ----------------- loading
                  child: Column(
                    children: [
                      const LinearProgressIndicator(),
                      Expanded(
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Image.asset('assets/gif/saga_loading.gif', width: 180),
                              const SizedBox(height: 12),
                              Text('Loading Operators', style: TextStyle(color: Theme.of(context).colorScheme.onPrimaryContainer, fontWeight: FontWeight.w600), textScaler: const TextScaler.linear(1.3),)
                            ],
                          )
                        )
                      )
                    ],
                  ),
                );
              }
            },
          ),
        ),
    );
  }

  void filterOperatorListByText(String searchText) {
    searchString = searchText;
    if (searchText != "") {
      setState(() {
        filteredOperatorList = sortedOperatorList.where((logObj) => logObj.names.any((name) => name.toLowerCase().contains(searchText.toLowerCase()))).toList();
      });
    } else {
      setState(() {
        filteredOperatorList = [];
      });
    }
  }

  void showFilters(BuildContext context) {
    showModalBottomSheet<void>(
      constraints: BoxConstraints.loose(Size(MediaQuery.of(context).size.width, MediaQuery.of(context).size.height * 0.75)),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(45))),
      showDragHandle: false,
      clipBehavior: Clip.antiAlias,
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState){
            final readSearchProvider = context.read<SettingsProvider>();

            return DefaultTabController(
              initialIndex: 0,
              length: 3,
              child: SafeArea(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const TabBar(
                      tabs: <Widget>[
                        Tab(text: 'Show'),
                        Tab(text: 'Filters'),
                        Tab(text: 'Order'),
                      ],
                    ),
                    AutoScaleTabBarView(
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 12.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const ListTile(title: Text('view mode')),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                                child: Wrap (
                                  spacing: 10,
                                  children: [
                                    ChoiceChip(label: const Text('Avatar'), selected: readSearchProvider.getDisplayChip('avatar'), onSelected: (_) => setModalState(() => readSearchProvider.setDisplayChip('avatar'))),
                                    ChoiceChip(label: const Text('Portrait'), selected: readSearchProvider.getDisplayChip('portrait'), onSelected: (_) => setModalState(() => readSearchProvider.setDisplayChip('portrait'))),
                                  ],
                                ),
                              ),
                              Row(
                                mainAxisSize: MainAxisSize.max,
                                children: [
                                  const Expanded(flex: 3, child: Center(child: Text('row show'))),
                                  Expanded(flex: 7, child: Center(child: Slider(min: 2, max: 5, divisions: 3, value: readSearchProvider.operatorSearchDelegate.toDouble(), label: readSearchProvider.operatorSearchDelegate.toString(), onChanged: (value) => setModalState(() => readSearchProvider.operatorSearchDelegate = value.round().toInt()), allowedInteraction: SliderInteraction.tapAndSlide)))
                                ],
                              )
                            ],
                          ),
                        ),
                        const Center(
                          child: Text("It's rainy here"),
                        ),
                        Wrap (
                          children: [
                            ListTile(
                                leading: const Icon(Icons.text_snippet_outlined),
                                title: const Text('test'),
                                onTap: () {}),
                            ListTile(
                                leading: const Icon(Icons.text_snippet_outlined),
                                title: const Text('test'),
                                onTap: () {}),
                            ListTile(
                                leading: const Icon(Icons.text_snippet_outlined),
                                title: const Text('test'),
                                onTap: () {}),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              )
            );
          }
        );
      },
    ).whenComplete((){if (context.mounted) context.read<SettingsProvider>().writeOpPageSettings();});
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
      child: GridView.builder(
        cacheExtent: 1500,
        padding: EdgeInsets.fromLTRB(
            4.0,
            MediaQuery.paddingOf(context).top+4.0,
            4.0,
            MediaQuery.paddingOf(context).bottom+4.0
          ),
        itemCount: operators.length,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: settings.operatorSearchDelegate, 
          childAspectRatio: settings.getDisplayChip('portrait') ? 0.55 : 1.0
        ),
        itemBuilder: (context, index) {
          return OperatorContainer(index: index, operator: operators[index]);
        },
      ),
    );
  }
}
