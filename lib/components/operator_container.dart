import 'dart:ui';

import 'package:docsprts/pages/operators_page.dart';
import 'package:flutter/material.dart';
import 'package:glass_kit/glass_kit.dart';
import 'package:transparent_image/transparent_image.dart';

import 'package:docsprts/global_data.dart' as globals;

const List<Color?> rarityColors = [null,Color(0xFF9c9c9c),Color(0xFFd8dd5a),Color(0xFF4aabea),Color(0xFFcfc2d1),Color(0xFFf1c644), Color.fromARGB(255, 255, 93, 12)];


class OperatorContainer extends StatelessWidget {
  final Operator operator;
  final int index;

  const OperatorContainer({super.key, required this.index, required this.operator});

  @override
  Widget build(BuildContext context) {
    
    // get Assets from github.com/yuanyan3060/ArknightsGameResource repo
    final String ghAvatarLink = 'https://raw.githubusercontent.com/yuanyan3060/ArknightsGameResource/main/avatar/${operator.id}.png';
    final String ghPotraitLink = 'https://raw.githubusercontent.com/yuanyan3060/ArknightsGameResource/main/portrait/${operator.id}_1.png';

    String imgLink = '';
    if (globals.operatorDisplayAvatar) {imgLink = ghAvatarLink;} 
    else if (globals.operatorDisplayPotrait) {imgLink = ghPotraitLink;}

    return GlassContainer(
      isFrostedGlass: true,
      margin: const EdgeInsets.all(4.0),
      gradient: LinearGradient(
        colors: [rarityColors[operator.rarity]!.withAlpha(125), Colors.transparent],
        stops: const [0, 1],
        begin: const Alignment(-1.1, -0.7),
        end: const Alignment(1.0, 1.0),
      ),
      borderColor: rarityColors[operator.rarity],
      borderGradient: operator.rarity == 6 ? const LinearGradient(
        colors: [Color.fromARGB(255, 255, 93, 12), Color.fromARGB(255, 248, 215, 29), Color(0xffc5f503)],
        stops: [0, 0.45, 1],
        begin: Alignment.topLeft,
        end: Alignment(1.0, 1.0),
      ) : null,
      padding: const EdgeInsets.all(1.0),
      borderRadius: BorderRadius.circular(10.0),
      child: Stack(
        alignment: AlignmentDirectional.bottomCenter,
        children: [
          ClipRRect(borderRadius: BorderRadius.circular(10.0), child: FadeInImage.memoryNetwork(fit: BoxFit.fitWidth, placeholder: kTransparentImage, image: imgLink, imageErrorBuilder: (err, err2, err3){return const Center(child: Text('error loading img'));})),
          Container(decoration: BoxDecoration(borderRadius: BorderRadius.circular(10.0), gradient: const LinearGradient(colors: [Color.fromARGB(0, 0, 0, 0), Color.fromARGB(255, 0, 0, 0)],stops: [0.65, 1],begin: Alignment.topCenter,end: Alignment.bottomCenter,)),),
          Padding(
            padding: const EdgeInsets.only(bottom: 2.5),
            child: Text(globals.operatorSearchDelegate <=4 ? operator.name : '', textAlign: TextAlign.center, textScaler: TextScaler.linear(operator.name.length <= 7 ? 1 : globals.operatorSearchDelegate >= 3 ? (clampDouble(8/operator.name.length, 0.6, 1)) : 1), style: const TextStyle(color: Colors.white),),
          )
        ],
      ),
    );
  }
}