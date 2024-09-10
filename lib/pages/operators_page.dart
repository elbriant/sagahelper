import 'dart:async';
import 'dart:convert';

import 'dart:ui';

import 'package:docsprts/components/operator_container.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

import 'package:docsprts/global_data.dart' as globals;

/*
for later
item colors

Low#9c9c9c
Basic#d8dd5a
Primary#4aabea
Secondary#cfc2d1
Advanced#f1c644



*/




const Map<String, int> rticonv = {
  "TIER_6": 6,
  "TIER_5": 5,
  "TIER_4": 4,
  "TIER_3": 3,
  "TIER_2": 2,
  "TIER_1": 1,
};

int rarityToInt(String tier){
    return rticonv[tier]!;
}




class Operator {
  final Map<String, dynamic> operatorDict;
  final String id;
  final String name;
  final int rarity;

  

  const Operator({
    required this.operatorDict,
    required this.id,
    required this.name,
    required this.rarity,
  });

  factory Operator.fromJson(String key, Map<String, dynamic> dict) {
    return Operator(
      operatorDict: dict,
      id: key,
      name: dict['name'] as String,
      rarity: rarityToInt(dict['rarity'])
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
      if((value['subProfessionId'] as String).startsWith('notchar')||key.startsWith('trap')||key.startsWith('token')||value['isNotObtainable'] == true ) {} 
      else {
        opsLists.add(Operator.fromJson(key, value));
      }
      
    }
  );
  return opsLists;
}











class OperatorsPage extends StatefulWidget {
  const OperatorsPage({super.key});

  @override
  State<OperatorsPage> createState() => _OperatorsPageState();
}

class _OperatorsPageState extends State<OperatorsPage> {
  
  late Future<List<Operator>> futureOperatorList;

  @override
  void initState() {
    super.initState();
    futureOperatorList = fetchOperators();
  }

  void searchOperator() {
    setState(() {
      globals.operatorSearchDelegate += 1;
    });
  }

  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        scrolledUnderElevation: 0,
        title: const Text('Operators'),
        flexibleSpace: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
            child: Container(
              color: Colors.transparent,
            ),
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(onPressed: searchOperator, icon: Icon(Icons.search)),
          IconButton(onPressed: () => showFilters(context), icon: Icon(Icons.filter_list)),
          MenuAnchor(
            menuChildren: [],
            builder: (BuildContext context, MenuController controller, Widget? child) {
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
            }
          ),
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
              return OperatorListView(operators: snapshot.data!);
            } else {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
          },
        ),
      ),
      backgroundColor: Theme.of(context).colorScheme.surfaceContainerLowest,
    );
  }

  void showFilters(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      builder: (BuildContext context) {
        return const DefaultTabController(
          initialIndex: 1,
          length: 3,
          child: Scaffold (
            appBar: TabBar(
                tabs: <Widget>[
                  Tab(
                    icon: Icon(Icons.cloud_outlined),
                  ),
                  Tab(
                    icon: Icon(Icons.beach_access_sharp),
                  ),
                  Tab(
                    icon: Icon(Icons.brightness_5_sharp),
                  ),
                ],
              ),
            body: TabBarView(
              children: <Widget>[
                Center(
                  child: Text("It's cloudy here"),
                ),
                Center(
                  child: Text("It's rainy here"),
                ),
                Center(
                  child: Text("It's sunny here"),
                ),
              ],
            )
          )
        );
      },
      showDragHandle: false,
    );
  }
}


class OperatorListView extends StatelessWidget {
  final List<Operator> operators;
  const OperatorListView({super.key, required this.operators});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.only(top: 100.0, left: 4.0, right: 4.0, bottom: 132.0), //hard coded, for top and bottom should get appbar's height and bottomNavBar height respectively
      itemCount: operators.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: globals.operatorSearchDelegate),
      itemBuilder: (context, index) {return OperatorContainer(index: index, operator: operators[index]);},
    );
  }
}