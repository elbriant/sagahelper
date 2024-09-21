import 'dart:async';
import 'dart:convert';
import 'package:docsprts/components/operator_container.dart';
import 'package:docsprts/providers/settings_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:autoscale_tabbarview/autoscale_tabbarview.dart';
import 'package:provider/provider.dart';
import 'package:docsprts/providers/ui_provider.dart';
import 'package:docsprts/components/traslucent_ui.dart';


const Map<String, int> rticonv = {
  "TIER_6": 6,
  "TIER_5": 5,
  "TIER_4": 4,
  "TIER_3": 3,
  "TIER_2": 2,
  "TIER_1": 1,
};

int rarityToInt(String tier) {
  return rticonv[tier]!;
}

class Operator {
  final Map<String, dynamic> operatorDict;
  final String id;
  final String name;
  final String? displayNumber;
  final String description;
  final String? nationId;
  final String? groupId;
  final String? teamId;
  final String position;
  final List<dynamic> tagList;
  final int rarity;
  final String profession;
  final String subProfessionId;
  final String itemUsage;
  final String itemDesc;

  const Operator({
    required this.operatorDict,
    required this.id,
    required this.name,
    required this.rarity,
    required this.displayNumber,
    required this.description,
    required this.nationId,
    required this.groupId,
    required this.teamId,
    required this.position,
    required this.profession,
    required this.subProfessionId,
    required this.tagList,
    required this.itemUsage,
    required this.itemDesc

  });

  factory Operator.fromJson(String key, Map<String, dynamic> dict) {
    return Operator(
        operatorDict: dict,
        id: key,
        name: dict['name'],
        rarity: rarityToInt(dict['rarity']),
        description: dict['description'],
        displayNumber: dict['displayNumber'],
        groupId: dict['groupId'],
        nationId: dict['nationId'],
        teamId: dict['teamId'],
        position: dict['position'],
        profession: dict['profession'],
        subProfessionId: dict['subProfessionId'],
        tagList: dict['tagList'],
        itemUsage: dict['itemUsage'],
        itemDesc: dict['itemDesc']
    );
  }
}

Future<String> getJson() {
  return rootBundle.loadString('assets/excel/character_table.json');
}

Future<List<Operator>> fetchOperators() async {
  final response = await getJson();
  // Use the compute function to run parsing in a separate isolate.
  return compute(parseOperators, response);
}

List<Operator> parseOperators(String response) {
  final parsed = jsonDecode(response) as Map<String, dynamic>;
  List<Operator> opsLists = [];
  parsed.forEach((key, value) {
    if ((value['subProfessionId'] as String).startsWith('notchar') ||
        key.startsWith('trap') ||
        key.startsWith('token') ||
        value['isNotObtainable'] == true) {
    } else {
      opsLists.add(Operator.fromJson(key, value));
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
  List<Operator> filteredOperatorList = [];

  bool isSearching = false;

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
            if (snapshot.hasError) {
              return const Center(
                child: Text('An error has occurred!'),
              );
            } else if (snapshot.hasData) {
              finishedFutureOperatorList = snapshot.data!;
              return OperatorListView(operators: isSearching ? (filteredOperatorList.isEmpty ? snapshot.data! : filteredOperatorList) : snapshot.data!);
            } else {
              return const Center(
                child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [CircularProgressIndicator(), SizedBox(height: 30), Text('Loading operators')],),
              );
            }
          },
        ),
      ),
    );
  }

  void filterOperatorListByText(String searchText) {
    if (searchText != "") {
      setState(() {
        filteredOperatorList = finishedFutureOperatorList.where((logObj) => logObj.name.toLowerCase().contains(searchText.toLowerCase())).toList();
      });
    } else {
    setState(() {
        filteredOperatorList = finishedFutureOperatorList;
      });
    }
  }

  void searchOperator() {
    setState(() {
      isSearching = true;
    });
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
        padding: const EdgeInsets.only(
            top: 100.0,
            left: 4.0,
            right: 4.0,
            bottom:
                132.0), //hard coded, for top and bottom should get appbar's height and bottomNavBar height respectively
        itemCount: operators.length,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: settings.operatorSearchDelegate, childAspectRatio: settings.getDisplayChip('portrait') ? 0.55 : 1.0),
        itemBuilder: (context, index) {
          return OperatorContainer(index: index, operator: operators[index]);
        },
      ),
    );
  }
}
