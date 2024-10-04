import 'dart:async';
import 'dart:convert';
import 'package:docsprts/components/operator_container.dart';
import 'package:docsprts/global_data.dart';
import 'package:docsprts/providers/server_provider.dart';
import 'package:docsprts/providers/settings_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:autoscale_tabbarview/autoscale_tabbarview.dart';
import 'package:provider/provider.dart';
import 'package:docsprts/providers/ui_provider.dart';
import 'package:docsprts/components/traslucent_ui.dart';
import 'package:docsprts/components/utils.dart';

const List<String> professionList = ['caster', 'medic', 'pioneer', 'sniper', 'special', 'support', 'tank', 'warrior'];
//TODO complete this for filters
const List<String> subProfessionList = ['agent', 'alchemist', 'aoesniper', 'artsfghter', 'artsprotector', 'bard', 'bearer', 'blastcaster', 'blessing', 'bombarder', 'centurion', 'chain', 'chainhealer', 'charger', ''];

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
  final List<String> names;
  final Map<String, dynamic> loreInfo;
  final Map<String, dynamic> voiceLangDict;
  final List<Map<String, dynamic>> charWordsList;
  final List<Map<String, dynamic>> skinsList;

  Operator({
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
    required this.itemDesc,
    required this.names,
    required this.loreInfo,
    required this.voiceLangDict,
    required this.charWordsList,
    required this.skinsList
  });

  String professionTranslate (String prof) => switch (prof) {
    'pioneer' => 'Vanguard',
    'special' => 'Specialist',
    'support' => 'Supporter',
    'tank' => 'Defender',
    'warrior' => 'Guard',
    String() => prof.capitalize(),
  };

  String get professionString => professionTranslate(profession.toLowerCase());

  //TODO earthshaker subclass
  String subProfessionTranslate(String subprof) => switch (subprof) {
    'corecaster' => 'Core',
    'splashcaster' => 'Splash',
    'blastcaster' => 'Blast',
    'funnel' => 'Mech-Accord',
    'primcaster' => 'Primal',
    'unyield' => 'Juggernaut',
    'artsprotector' => 'Arts Protector',
    'shotprotector' => 'Sentry Protector',
    'fearless' => 'Dreadnought',
    'artsfghter' => 'Arts Fighter',
    'sword' => 'Swordmaster',
    'musha' => 'Soloblade',
    'librator' => 'Liberator',
    'physician' => 'Medic',
    'ringhealer' => 'Multi-Target',
    'healer' => 'Therapist',
    'wandermedic' => 'Wandering',
    'incantationmedic' => 'Incantation',
    'chainhealer' => 'Chain',
    'fastshot' => 'Marksman',
    'aoesniper' => 'Artilleryman',
    'longrange' => 'Deadeye',
    'closerange' => 'Heavyshooter',
    'reaperrange' => 'Spreadshooter',
    'siegesniper' => 'Besieger',
    'bombarder' => 'Flinger',
    'pusher' => 'Push Stroker',
    'stalker' => 'Ambusher',
    'traper' => 'Trapmaster',
    'slower' => 'Dencel Binder',
    'underminer' => 'Hexer',
    'blessing' => 'Abjurer',
    'craftsman' => 'Artificer',
    'bearer' => 'Standard Bearer',
    String() => subprof.capitalize()
  };

  String get subProfessionString => subProfessionTranslate(subProfessionId.toLowerCase());

  factory Operator.fromJson(String key, Map<String, dynamic> dict, Map<String, dynamic> loreDict, Map<String, dynamic> voiceDict, Map<String, dynamic> charSkins) {
    //custom names
    String name = dict['name'];
    var names = <String>[name];

    if (name == 'Pozëmka') names.addAll(['pozemka']);
    if (name == 'Rosa') names.addAll(['poca']);
    if (name == 'Ling') names.addAll(['blue woman']);
    if (name == "Ch'en" || name == "Ch'en the Holungday") names.addAll(['chen', 'blue woman']);
    if (name == 'Młynar') names.addAll(['mlynar', 'milnar']);

    List<Map<String, dynamic>> getVoices(Map<String, dynamic> charWords, String opKey) {
      List<Map<String, dynamic>> result = [];

      charWords.forEach((key, value){
        if (key.startsWith('${opKey}_')) {
          result.add(value);
        }
      });
      return result;
    }

    List<Map<String, dynamic>> getSkins(Map<String, dynamic> charskins, String opKey) {
      List<Map<String, dynamic>> result = [];
      charskins.forEach((key, value){
        if (key.startsWith(opKey)) {
          result.add(value);
        }
      });
      return result;
    }

    return Operator(
        operatorDict: dict,
        id: key,
        name: dict['name'],
        rarity: int.parse((dict['rarity'] as String).replaceAll('TIER_', '')),
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
        itemDesc: dict['itemDesc'],
        names: names,
        loreInfo: loreDict[key],
        voiceLangDict: voiceDict['voiceLangDict'][key],
        charWordsList: getVoices(voiceDict['charWords'], key),
        skinsList: getSkins(charSkins, key)
    );
  }
}

Future<List<Operator>> fetchOperators() async {
  List<String> files = ['/excel/character_table.json', '/excel/handbook_info_table.json', '/excel/charword_table.json', '/excel/skin_table.json'];
  // 0 operators
  // 1 lore
  // 2 voice
  // 3 skin

  try {
    await NavigationService.navigatorKey.currentContext!.read<ServerProvider>().existFiles(NavigationService.navigatorKey.currentContext!.read<SettingsProvider>().currentServerString, files);
  } catch (e) {
    throw FormatException('Update gamedata [error:$e]');
  }

  List<String> response = [];

  for (String filepath in files) {
    response.add(await NavigationService.navigatorKey.currentContext!.read<ServerProvider>().getFile(filepath, NavigationService.navigatorKey.currentContext!.read<SettingsProvider>().currentServerString));
  }

  // Use the compute function to run parsing in a separate isolate.
  return compute(parseOperators, response);
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
              if (snapshot.hasError) {
                if (snapshot.error is FormatException) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Image.asset('assets/gif/saga_err.gif', width: 180),
                        const SizedBox(height: 12),
                        Text(snapshot.error.toString(), style: TextStyle(color: Theme.of(context).colorScheme.error))
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
                        Text('An unknown error has ocurred!', style: TextStyle(color: Theme.of(context).colorScheme.error))
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
                          Image.asset('assets/gif/saga_err.gif', width: 180),
                          const SizedBox(height: 12),
                          Text('operator not found', style: TextStyle(color: Theme.of(context).colorScheme.error))
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
                return SafeArea(
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
                              const Text('loading operators')
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
        padding: EdgeInsets.only(
            top: MediaQuery.paddingOf(context).top+4.0,
            left: 4.0,
            right: 4.0,
            bottom: MediaQuery.paddingOf(context).bottom+4.0
          ), //hard coded, for top and bottom should get appbar's height and bottomNavBar height respectively
        itemCount: operators.length,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: settings.operatorSearchDelegate, childAspectRatio: settings.getDisplayChip('portrait') ? 0.55 : 1.0),
        itemBuilder: (context, index) {
          return OperatorContainer(index: index, operator: operators[index]);
        },
      ),
    );
  }
}
