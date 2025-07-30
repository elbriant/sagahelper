import 'package:flutter/material.dart';
import 'package:network_to_file_image/network_to_file_image.dart';
import 'package:provider/provider.dart';
import 'package:sagahelper/components/operator_info_page/operator_container.dart';
import 'package:sagahelper/components/popup_dialog.dart';
import 'package:sagahelper/core/global_data.dart';

import 'package:sagahelper/models/entity.dart';
import 'package:sagahelper/providers/op_info_provider.dart';
import 'package:sagahelper/providers/styles_provider.dart';
import 'package:sagahelper/utils/extensions.dart';
import 'package:styled_text/styled_text.dart';
import 'package:transparent_image/transparent_image.dart';

class EntityCard extends StatelessWidget {
  const EntityCard({
    super.key,
    required this.entity,
  });

  final Entity entity;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(
          color: rarityColors[0],
          width: 2.0,
          strokeAlign: BorderSide.strokeAlignOutside,
        ),
        color: rarityColors[0].withValues(alpha: 0.4),
      ),
      clipBehavior: Clip.none,
      margin: const EdgeInsets.fromLTRB(4.0, 8.0, 4.0, 4.0),
      constraints: BoxConstraints.loose(const Size(double.maxFinite, 60)),
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: () => PopupDialog.entityView(
            context: context,
            entity: Entity.fromId(
              id: entity.id,
              elite: entity.elite ?? context.read<OpInfoProvider?>()?.elite,
              lv: entity.level ?? context.read<OpInfoProvider?>()?.level.toInt(),
              pot: entity.potential ?? context.read<OpInfoProvider?>()?.potential,
              selectedSkill: entity.selectedSkill ?? context.read<OpInfoProvider?>()?.selectedSkill,
              skillLevel: entity.selectedSkillLv ?? context.read<OpInfoProvider?>()?.skillLevel,
            ),
          ),
          splashColor: rarityColors[0].withValues(alpha: 0.4),
          highlightColor: rarityColors[0].withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(8.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(2),
                  border: Border.all(
                    color: rarityColors[0],
                    width: 2.0,
                    strokeAlign: BorderSide.strokeAlignOutside,
                  ),
                  color: HSLColor.fromColor(rarityColors[0]).withLightness(0.10).toColor(),
                ),
                child: FadeInImage(
                  image: NetworkToFileImage(
                    url: '$kTokenAvatarRepo/${entity.id}.png'.githubEncode(),
                    file: LocalDataManager.localCacheFileSync('entityAvatar/${entity.id}.png'),
                  ),
                  filterQuality: FilterQuality.high,
                  placeholder: MemoryImage(kTransparentImage),
                  width: 60,
                  height: 60,
                  imageErrorBuilder: (context, error, stackTrace) => const SizedBox.square(
                    dimension: 60,
                    child: Center(
                      child: Icon(
                        Icons.error,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(
                width: 6.0,
              ),
              Expanded(
                child: ConstrainedBox(
                  constraints: BoxConstraints.loose(const Size(double.maxFinite, 60)),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        entity.name,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: HSLColor.fromColor(Theme.of(context).primaryColor)
                              .withLightness(0.75)
                              .toColor(),
                          overflow: TextOverflow.ellipsis,
                          fontWeight: FontWeight.w600,
                          shadows: const [
                            Shadow(color: Color.fromARGB(157, 0, 0, 0), blurRadius: 6),
                          ],
                        ),
                      ),
                      StyledText(
                        text: entity.description,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        async: true,
                        style: const TextStyle(
                          color: Colors.white,
                          shadows: [Shadow(color: Color.fromARGB(157, 0, 0, 0), blurRadius: 6)],
                        ),
                        tags: context.read<StyleProvider>().tagsAsArknights(context: context),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(
                width: 6.0,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
