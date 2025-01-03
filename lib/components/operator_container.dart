import 'package:cached_network_image/cached_network_image.dart';
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
    void openOperatorInfo(Operator currOp) {
      Navigator.of(context).push(MaterialPageRoute(builder: (context) => OperatorInfo(currOp)));
    }

    final String ghAvatarLink = '$kAvatarRepo/${operator.id}.png';
    final String ghPotraitLink = '$kPortraitRepo/${operator.id}_1.png';

    final settings = context.watch<SettingsProvider>();

    String imgLink = switch (settings.getDisplayChipStr()) {
      'avatar' => ghAvatarLink,
      'portrait' => ghPotraitLink,
      String() => ''
    };

    return GlassContainer(
      isFrostedGlass: settings.operatorSearchDelegate <= 4 ? true : false,
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
      child: Stack(
        alignment: AlignmentDirectional.bottomCenter,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10.0),
            child: Hero(
              tag: operator.id,
              child: CachedNetworkImage(
                cacheKey: operator.id,
                imageUrl: imgLink,
                fit: BoxFit.fitWidth,
                memCacheHeight: settings.getDisplayChipStr() == 'avatar' ? 180 : 360,
                memCacheWidth: 180,
                placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
                errorWidget: (context, url, error) => const Center(child: Icon(Icons.error)),
              ),
            ),
          ),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10.0),
                gradient: settings.operatorSearchDelegate <= 4
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
          settings.operatorSearchDelegate <= 4
              ? Padding(
                  padding: const EdgeInsets.only(bottom: 2.5),
                  child: Text(
                    operator.name,
                    textAlign: TextAlign.center,
                    textScaler: operator.name.length > 7
                        // ignore: deprecated_member_use
                        ? TextScaler.linear(
                            // ignore: deprecated_member_use
                            (MediaQuery.textScalerOf(context).textScaleFactor -
                                    (operator.name.length - 7) / 100) *
                                (3 / settings.operatorSearchDelegate),
                          )
                        // ignore: deprecated_member_use
                        : TextScaler.linear(
                            // ignore: deprecated_member_use
                            MediaQuery.textScalerOf(context).textScaleFactor *
                                (3 / settings.operatorSearchDelegate),
                          ),
                    style: const TextStyle(color: Colors.white),
                  ),
                )
              : null,
          Material(
            type: MaterialType.transparency,
            child: InkWell(
              onTap: () => openOperatorInfo(operator),
            ),
          ),
        ].nullParser(),
      ),
    );
  }
}
