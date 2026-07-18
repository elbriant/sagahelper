import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:network_to_file_image/network_to_file_image.dart';
import 'package:sagahelper/core/global_data.dart';
import 'package:sagahelper/models/config/local_data_manager.dart';
import 'package:sagahelper/models/config/types.dart';
import 'package:sagahelper/models/operator.dart';
import 'package:sagahelper/pages/operator/skeleton.dart';
import 'package:sagahelper/components/operator_info_page/operator_container.dart';
import 'package:sagahelper/providers/connectivity_provider.dart';

class OperatorLilCard extends ConsumerWidget {
  const OperatorLilCard({super.key, required this.operator});
  final Operator operator;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    void openOperatorInfo() {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => OperatorInfoSkeletonPage(
            operator: operator,
          ),
        ),
      );
    }

    final String imgLink =
        '$kAvatarRepo/${operator.id}${opIdMustHaveE2avatar.contains(operator.id) ? '_2' : ''}.png';

    final isConnected = ref.watch(effectiveIsConnectedProvider);
    final cacheFile = LocalDataManager.localCacheFile(
      '${operator.id}_dl${OperatorDisplayMode.avatar.index.toString()}.png',
      CacheType.operatorAvatar,
    );

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(
          color: rarityColors[operator.rarity],
          width: 1.0,
          strokeAlign: BorderSide.strokeAlignOutside,
        ),
      ),
      clipBehavior: Clip.hardEdge,
      margin: const EdgeInsets.only(left: 6.0, top: 4.0, bottom: 4.0),
      child: Material(
        child: Ink(
          height: 50,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: (!isConnected)
                  ? (cacheFile.existsSync()
                      ? FileImage(cacheFile)
                      : const AssetImage('assets/placeholders/original.png'))
                  : NetworkToFileImage(
                      file: cacheFile,
                      url: imgLink,
                    ),
              opacity: 0.6,
              alignment: const Alignment(0, 0.3),
              fit: BoxFit.cover,
            ),
            borderRadius: BorderRadius.circular(8.0),
            gradient: LinearGradient(
              colors: [
                rarityColors[operator.rarity].withAlpha(125),
                Colors.transparent,
              ],
              stops: const [0, 1],
              begin: const Alignment(-1.1, -0.7),
              end: const Alignment(1.0, 1.0),
            ),
          ),
          child: InkWell(
            onTap: openOperatorInfo,
            splashColor: rarityColors[operator.rarity].withAlpha(60),
            highlightColor: rarityColors[operator.rarity].withAlpha(55),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6.0),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    operator.name,
                    style: TextStyle(
                      color: HSLColor.fromColor(rarityColors[operator.rarity])
                          .withLightness(
                            Theme.of(context).brightness == Brightness.light ? 0.16 : 0.65,
                          )
                          .toColor(),
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                      shadows: Theme.of(context).brightness == Brightness.dark
                          ? [const Shadow(blurRadius: 1.2)]
                          : null,
                    ),
                  ),
                  const SizedBox(width: 8.0),
                  _DecoratedClassImage(
                    AssetImage(
                      'assets/classes/class_${operator.profession.toLowerCase()}.png',
                    ),
                  ),
                  _DecoratedClassImage(
                    AssetImage(
                      'assets/subclasses/sub_${operator.subProfessionId.toLowerCase()}_icon.png',
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DecoratedClassImage extends StatelessWidget {
  const _DecoratedClassImage(this.image);
  final ImageProvider image;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color:
            HSLColor.fromColor(Theme.of(context).colorScheme.primary).withLightness(0.10).toColor(),
        shape: BoxShape.circle,
        border: Border.all(
          color: Theme.of(context).colorScheme.outline,
        ),
      ),
      child: SizedBox.square(
        dimension: 40,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Image(
            image: image,
            fit: BoxFit.scaleDown,
          ),
        ),
      ),
    );
  }
}
