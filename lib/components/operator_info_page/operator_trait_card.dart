import 'package:flutter_riverpod/flutter_riverpod.dart';
// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:network_to_file_image/network_to_file_image.dart';
import 'package:sagahelper/components/shimmer_loading_mask.dart';
import 'package:sagahelper/core/asset_service.dart';
import 'package:sagahelper/core/global_data.dart';
import 'package:sagahelper/models/config/local_data_manager.dart';
import 'package:sagahelper/providers/connectivity_provider.dart';
import 'package:sagahelper/providers/operator_context_provider.dart';
import 'package:sagahelper/providers/style_provider.dart';
import 'package:sagahelper/utils/extensions.dart';
import 'package:styled_text/styled_text.dart';
import 'package:sagahelper/models/operator.dart';

String computeTraitText(input) {
  // [operator, elite]
  Map? candidate;
  if (input[0].trait != null) {
    candidate = (input[0].trait["candidates"] as List?)?.lastWhere(
      (candidate) =>
          input[1] >=
          int.parse(
            (candidate["unlockCondition"]["phase"] as String).replaceFirst('PHASE_', ''),
          ),
    );
  }

  final String result = ((candidate?["overrideDescripton"] ??
          input[0].description ??
          '<i-sub> no trait <i-sub>') as String)
      .varParser(candidate?["blackboard"])
      .akRichTextParser();
  return result;
}

class TraitCard extends ConsumerWidget {
  const TraitCard({
    super.key,
    required this.operator,
  });
  final Operator operator;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final elite = ref.watch(operatorContextProvider.select((p) => p.elite));
    final tagsAsArknights = ref.watch(styleProvider).tagsAsArknights;
    final isConnected = ref.watch(effectiveIsConnectedProvider);
    final subIconAsset = "assets/subclasses/sub_${operator.subProfessionId.toLowerCase()}_icon.png";
    final subIconNetwork =
        "$kSubProfessionIconRepo/sub_${operator.subProfessionId.toLowerCase()}_icon.png";

    return FutureBuilder(
      future: compute(computeTraitText, [operator, elite]),
      builder: (context, snapshot) {
        final cacheFile = LocalDataManager.localCacheFile(
          "sub_${operator.subProfessionId.toLowerCase()}_icon.png",
        );
        return _TraitCard(
          label: Text(
            '${operator.professionString} - ${operator.subProfessionString}',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          avatar: AssetService.assetSet.contains(subIconAsset)
              ? AssetImage(subIconAsset)
              : (!isConnected)
                  ? (cacheFile.existsSync()
                      ? FileImage(cacheFile)
                      : const AssetImage('assets/placeholders/original.png'))
                  : NetworkToFileImage(
                      file: cacheFile,
                      url: subIconNetwork,
                    ),
          content: AnimatedSize(
            duration: const Duration(milliseconds: 150),
            curve: Curves.ease,
            alignment: Alignment.centerLeft,
            child: (!(snapshot.connectionState == ConnectionState.done))
                ? ShimmerLoadingMask(
                    child: Container(
                      margin: const EdgeInsets.all(2.0),
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      width: double.maxFinite,
                      height: 14,
                    ),
                  )
                : StyledText(
                    text: snapshot.data!,
                    tags: tagsAsArknights,
                    textAlign: TextAlign.start,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSecondaryContainer,
                    ),
                  ),
          ),
        );
      },
    );
  }
}

class _TraitCard extends StatelessWidget {
  final Text label;
  final Widget content;
  final ImageProvider avatar;
  const _TraitCard({required this.label, required this.content, required this.avatar});

  @override
  Widget build(BuildContext context) {
    return Card.filled(
      margin: const EdgeInsets.only(top: 6.0, bottom: 18.0),
      elevation: 1.0,
      child: Container(
        width: double.maxFinite,
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                Container(
                  margin: const EdgeInsets.only(bottom: 12.0, top: 8.0),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Theme.of(context).colorScheme.outline,
                    ),
                  ),
                  padding: const EdgeInsets.only(
                    top: 2.0,
                    bottom: 2.0,
                    right: 12.0,
                    left: 42,
                  ),
                  child: label,
                ),
                Positioned(
                  left: 0,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: HSLColor.fromColor(Theme.of(context).colorScheme.primary)
                          .withLightness(0.10)
                          .toColor(),
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
                          image: avatar,
                          fit: BoxFit.scaleDown,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            content,
          ],
        ),
      ),
    );
  }
}
