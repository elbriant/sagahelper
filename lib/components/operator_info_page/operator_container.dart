import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gradient_borders/box_borders/gradient_box_border.dart';
import 'package:sagahelper/components/stored_image.dart';
import 'package:sagahelper/core/global_data.dart';
import 'package:sagahelper/models/config/local_data_manager.dart';
import 'package:sagahelper/models/config/types.dart' show OperatorDisplayMode;
import 'package:sagahelper/models/filters.dart';
import 'package:sagahelper/models/operator.dart';
import 'package:sagahelper/pages/operator/skeleton.dart';
import 'package:sagahelper/providers/config_provider.dart';
import 'package:flutter/material.dart';
import 'package:sagahelper/providers/operator_search_provider.dart';

const List<Color> rarityColors = [
  Color.fromARGB(255, 69, 69, 69), // entities
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

class OperatorContainer extends ConsumerWidget {
  final Operator op;
  final int index;

  const OperatorContainer({
    super.key,
    required this.index,
    required this.op,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final String ghAvatarLink =
        '$kAvatarRepo/${op.id}${opIdMustHaveE2avatar.contains(op.id) ? '_2' : ''}.png';
    final String ghPotraitLink =
        '$kPortraitRepo/${op.id}${opIdMustHaveE2Portrait.contains(op.id) ? '_2' : '_1'}.png';

    final opDisplay = ref.watch(configProvider.select((p) => p.operatorDisplayMode));
    final searchDelegate = ref.watch(configProvider.select((p) => p.operatorSearchDelegate));

    String imgLink = switch (opDisplay) {
      OperatorDisplayMode.avatar => ghAvatarLink,
      OperatorDisplayMode.portrait => ghPotraitLink,
    };

    void openOperatorInfo(Operator currOp) async {
      FilterTag? filter = await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => OperatorInfoSkeletonPage(
            operator: currOp,
          ),
        ),
      );
      if (filter != null) {
        ref.read(operatorSearchProvider.notifier)
          ..clearOperatorFilters()
          ..addOperatorFilter(filter);
      }
    }

    return Container(
      margin: const EdgeInsets.all(4.0),
      decoration: BoxDecoration(
        border: op.rarity == 6
            ? const GradientBoxBorder(
                gradient: LinearGradient(
                  colors: [
                    Color.fromARGB(255, 255, 93, 12),
                    Color.fromARGB(255, 248, 215, 29),
                    Color(0xffc5f503),
                  ],
                  stops: [0, 0.45, 1],
                  begin: Alignment.topLeft,
                  end: Alignment(1.0, 1.0),
                ),
                width: 1.0,
              )
            : Border.all(color: rarityColors[op.rarity]),
        borderRadius: BorderRadius.circular(10.0),
        gradient: LinearGradient(
          colors: [
            rarityColors[op.rarity].withAlpha(125),
            Colors.transparent,
          ],
          stops: const [0, 1],
          begin: const Alignment(-1.1, -0.7),
          end: const Alignment(1.0, 1.0),
        ),
        boxShadow: [
          const BoxShadow(
            blurRadius: 3.0,
            blurStyle: BlurStyle.outer,
            color: Colors.black45,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(9.0),
        clipBehavior: Clip.hardEdge,
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            Hero(
              tag: op.id,
              child: StoredCustomImage(
                filename: '${op.id}_dl${opDisplay.index.toString()}.png',
                type: CacheType.operatorAvatar,
                imageUrl: imgLink,
                fit: BoxFit.fitWidth,
              ),
            ),
            Positioned.fill(
              child: Visibility(
                visible: searchDelegate <= 4,
                child: DecoratedBox(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Color.fromARGB(0, 0, 0, 0),
                        Color.fromARGB(100, 0, 0, 0),
                      ],
                      stops: [0.6, 1],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 1.5, left: 4, right: 4),
                      child: Text(
                        op.name,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                        textAlign: TextAlign.center,
                        textScaler: op.name.length > 7
                            // ignore: deprecated_member_use
                            ? TextScaler.linear(
                                // ignore: deprecated_member_use
                                (MediaQuery.textScalerOf(context).textScaleFactor -
                                        (op.name.length - 7) / 100) *
                                    (3 / searchDelegate),
                              )
                            // ignore: deprecated_member_use
                            : TextScaler.linear(
                                // ignore: deprecated_member_use
                                MediaQuery.textScalerOf(context).textScaleFactor *
                                    (3 / searchDelegate),
                              ),
                        style: const TextStyle(
                          color: Colors.white,
                          shadows: [Shadow(blurRadius: 1.5)],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Positioned.fill(
              child: Material(
                type: MaterialType.transparency,
                child: InkWell(
                  splashColor: rarityColors[op.rarity].withAlpha(45),
                  highlightColor: rarityColors[op.rarity].withAlpha(35),
                  onTap: () => openOperatorInfo(op),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
