import 'package:sagahelper/components/stored_image.dart';
import 'package:sagahelper/utils/extensions.dart';
import 'package:sagahelper/global_data.dart';
import 'package:sagahelper/models/operator.dart';
import 'package:sagahelper/pages/operator_info_page.dart';
import 'package:sagahelper/providers/settings_provider.dart';
import 'package:flutter/material.dart';
import 'package:glass_kit/glass_kit.dart';
import 'package:provider/provider.dart';

const List<Color?> rarityColors = [
  null,
  Color(0xFF9c9c9c),
  Color(0xFFd8dd5a),
  Color(0xFF4aabea),
  Color(0xFFcfc2d1),
  Color(0xFFf1c644),
  Color.fromARGB(255, 255, 93, 12),
];

const List<String> opIdMustHaveE2avatar = [
  'char_1037_amiya3',
];

const List<String> opIdMustHaveE2Portrait = [
  'char_1001_amiya2',
  'char_1037_amiya3',
];

class OperatorContainer extends StatelessWidget {
  final Operator operator;
  final int index;

  const OperatorContainer({
    super.key,
    required this.index,
    required this.operator,
  });

  @override
  Widget build(BuildContext context) {
    final String ghAvatarLink =
        '$kAvatarRepo/${operator.id}${opIdMustHaveE2avatar.contains(operator.id) ? '_2' : ''}.png';
    final String ghPotraitLink =
        '$kPortraitRepo/${operator.id}${opIdMustHaveE2Portrait.contains(operator.id) ? '_2' : '_1'}.png';

    final opDisplay = context.select<SettingsProvider, DisplayList>((prov) => prov.operatorDisplay);
    final searchDelegate =
        context.select<SettingsProvider, int>((prov) => prov.operatorSearchDelegate);

    String imgLink = switch (opDisplay) {
      DisplayList.avatar => ghAvatarLink,
      DisplayList.portrait => ghPotraitLink,
    };

    void openOperatorInfo(Operator currOp) {
      Navigator.of(context).push(MaterialPageRoute(builder: (context) => OperatorInfo(currOp)));
    }

    return GlassContainer(
      isFrostedGlass: searchDelegate <= 4 ? true : false,
      margin: const EdgeInsets.all(4.0),
      gradient: LinearGradient(
        colors: [
          rarityColors[operator.rarity]!.withAlpha(125),
          Colors.transparent,
        ],
        stops: const [0, 1],
        begin: const Alignment(-1.1, -0.7),
        end: const Alignment(1.0, 1.0),
      ),
      borderColor: rarityColors[operator.rarity],
      borderGradient: operator.rarity == 6
          ? const LinearGradient(
              colors: [
                Color.fromARGB(255, 255, 93, 12),
                Color.fromARGB(255, 248, 215, 29),
                Color(0xffc5f503),
              ],
              stops: [0, 0.45, 1],
              begin: Alignment.topLeft,
              end: Alignment(1.0, 1.0),
            )
          : null,
      padding: const EdgeInsets.all(1.0),
      borderRadius: BorderRadius.circular(10.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10.0),
        clipBehavior: Clip.hardEdge,
        child: Stack(
          alignment: AlignmentDirectional.bottomCenter,
          children: [
            Positioned.fill(
              child: StoredImage(
                filePath: 'images/${operator.id}_dl${opDisplay.index.toString()}.png',
                imageUrl: imgLink,
                boxFit: BoxFit.fitWidth,
                heroTag: operator.id,
              ),
            ),
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10.0),
                  gradient: searchDelegate <= 4
                      ? const LinearGradient(
                          colors: [
                            Color.fromARGB(0, 0, 0, 0),
                            Color.fromARGB(255, 0, 0, 0),
                          ],
                          stops: [0.65, 1],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        )
                      : null,
                ),
              ),
            ),
            searchDelegate <= 4
                ? Padding(
                    padding: const EdgeInsets.only(bottom: 2.5, left: 4, right: 4),
                    child: Text(
                      operator.name,
                      textAlign: TextAlign.center,
                      textScaler: operator.name.length > 7
                          // ignore: deprecated_member_use
                          ? TextScaler.linear(
                              // ignore: deprecated_member_use
                              (MediaQuery.textScalerOf(context).textScaleFactor -
                                      (operator.name.length - 7) / 100) *
                                  (3 / searchDelegate),
                            )
                          // ignore: deprecated_member_use
                          : TextScaler.linear(
                              // ignore: deprecated_member_use
                              MediaQuery.textScalerOf(context).textScaleFactor *
                                  (3 / searchDelegate),
                            ),
                      style: const TextStyle(color: Colors.white),
                    ),
                  )
                : null,
            Material(
              type: MaterialType.transparency,
              child: InkWell(
                splashColor: rarityColors[operator.rarity]!.withAlpha(45),
                highlightColor: rarityColors[operator.rarity]!.withAlpha(35),
                onTap: () => openOperatorInfo(operator),
              ),
            ),
          ].nullParser(),
        ),
      ),
    );
  }
}
