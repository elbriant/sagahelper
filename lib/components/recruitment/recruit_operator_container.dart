import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gradient_borders/box_borders/gradient_box_border.dart';
import 'package:sagahelper/components/operator_info_page/operator_container.dart' show rarityColors;
import 'package:sagahelper/components/stored_image.dart';
import 'package:sagahelper/core/global_data.dart';
import 'package:sagahelper/models/config/local_data_manager.dart';
import 'package:sagahelper/models/config/types.dart' show OperatorDisplayMode;
import 'package:sagahelper/models/recruit_operator.dart';
import 'package:sagahelper/pages/operator/skeleton.dart';

const _opIdMustHaveE2avatar = [
  'char_1037_amiya3',
];

class RecruitOperatorContainer extends ConsumerWidget {
  final RecruitOperator recruitOp;

  const RecruitOperatorContainer({
    super.key,
    required this.recruitOp,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final op = recruitOp.op;
    final isUnique = recruitOp.unique;

    final String ghAvatarLink =
        '$kAvatarRepo/${op.id}${_opIdMustHaveE2avatar.contains(op.id) ? '_2' : ''}.png';

    void openOperatorInfo() {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => OperatorInfoSkeletonPage(
            operator: op,
          ),
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.all(4.0),
      decoration: BoxDecoration(
        border: isUnique
            ? const GradientBoxBorder(
                gradient: LinearGradient(
                  colors: [
                    Color(0xFF00E676),
                    Color(0xFF00C853),
                    Color(0xFF69F0AE),
                    Color(0xFF00E676),
                  ],
                  stops: [0, 0.3, 0.7, 1],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                width: 2.0,
              )
            : op.rarity == 6
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
          if (isUnique)
            const BoxShadow(
              blurRadius: 8.0,
              blurStyle: BlurStyle.outer,
              color: Color(0xFF00E676),
              spreadRadius: -1.0,
            )
          else
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
            StoredCustomImage(
              key: ValueKey('${op.id}_dl${OperatorDisplayMode.avatar.index}.png'),
              filename: '${op.id}_dl${OperatorDisplayMode.avatar.index}.png',
              type: CacheType.operatorAvatar,
              imageUrl: ghAvatarLink,
              fit: BoxFit.fitWidth,
            ),
            Positioned.fill(
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
                      // ignore: deprecated_member_use
                      textScaler: op.name.length > 7
                          // ignore: deprecated_member_use
                          ? TextScaler.linear(
                              // ignore: deprecated_member_use
                              MediaQuery.textScalerOf(context).textScaleFactor -
                                  (op.name.length - 7) / 100,
                            )
                          // ignore: deprecated_member_use
                          : TextScaler.linear(
                              // ignore: deprecated_member_use
                              MediaQuery.textScalerOf(context).textScaleFactor,
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
            Positioned.fill(
              child: Material(
                type: MaterialType.transparency,
                child: InkWell(
                  splashColor: (isUnique ? const Color(0xFF00E676) : rarityColors[op.rarity])
                      .withAlpha(45),
                  highlightColor: (isUnique ? const Color(0xFF00E676) : rarityColors[op.rarity])
                      .withAlpha(35),
                  onTap: openOperatorInfo,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
