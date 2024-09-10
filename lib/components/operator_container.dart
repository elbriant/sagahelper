import 'package:docsprts/pages/operators_page.dart';
import 'package:flutter/material.dart';
import 'package:glass_kit/glass_kit.dart';
import 'package:transparent_image/transparent_image.dart';

import 'package:docsprts/global_data.dart' as globals;

const List<Color?> rarityColors = [null,Color(0xFF9c9c9c),Color(0xFFd8dd5a),Color(0xFF4aabea),Color(0xFFcfc2d1),Color(0xFFf1c644), Color.fromARGB(255, 255, 93, 12)];

String ghLink = 'https://raw.githubusercontent.com/Aceship/Arknight-Images/0b28f9562fcadbd644c6225f8f8aefbb500b4d22/avatars/';


class OperatorContainer extends StatelessWidget {
  final Operator operator;
  final int index;

  const OperatorContainer({super.key, required this.index, required this.operator});

  @override
  Widget build(BuildContext context) {

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
        colors: [Color.fromARGB(255, 255, 93, 12), Color(0xffeea702), Color(0xffc5f503)],
        stops: [0, 0.75, 1],
        begin: Alignment.topLeft,
        end: Alignment(1.0, 1.0),
      ) : null,
      padding: const EdgeInsets.all(1.0),
      borderRadius: BorderRadius.circular(10.0),
      child: Stack(
        alignment: AlignmentDirectional.bottomCenter,
        children: [
          Container(decoration: BoxDecoration(borderRadius: BorderRadius.circular(10.0)), clipBehavior: Clip.antiAlias, child: FadeInImage.memoryNetwork(placeholder: kTransparentImage, image: '$ghLink${operator.id}.png'), ),
          Container(decoration: BoxDecoration(borderRadius: BorderRadius.circular(10.0), gradient: const LinearGradient(colors: [Color.fromARGB(0, 0, 0, 0), Color.fromARGB(255, 0, 0, 0)],stops: [0.75, 1],begin: Alignment.topCenter,end: Alignment.bottomCenter,)),),
          Text(globals.operatorSearchDelegate <=4 ? operator.name : '')
        ],
      ),
    );
  }
}