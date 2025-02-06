import 'package:flutter/material.dart';
import 'package:sagahelper/components/stored_image.dart';
import 'package:sagahelper/global_data.dart';
import 'package:sagahelper/models/operator.dart';
import 'package:sagahelper/providers/settings_provider.dart';
import 'package:sagahelper/utils/extensions.dart';

class OpinfoArchiveHeader extends StatelessWidget {
  const OpinfoArchiveHeader({super.key, required this.operator, required this.relatedOps});
  final Operator operator;
  final Widget relatedOps;

  @override
  Widget build(BuildContext context) {
    final professionStr = 'assets/classes/class_${operator.profession.toLowerCase()}.png';
    final subprofessionStr =
        'assets/subclasses/sub_${operator.subProfessionId.toLowerCase()}_icon.png';

    final String ghAvatarLink = '$kAvatarRepo/${operator.id}.png';
    String? logo = operator.teamId ?? operator.groupId ?? operator.nationId;
    if (logo == 'laterano' || logo == 'leithanien') {
      logo = logo?.replaceFirst('l', 'L');
    }
    final String ghLogoLink = logo == 'laios' || logo == 'rainbow'
        ? '$kLogoRepo/linkage/logo_$logo.png'
        : '$kLogoRepo/logo_$logo.png';

    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Stack(
        children: [
          logo != null
              ? Positioned(
                  right: 1,
                  top: 0,
                  child: Container(
                    width: 180,
                    height: 180,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Theme.of(context).colorScheme.primary.withOpacity(0.25),
                          spreadRadius: 40,
                          blurRadius: 55,
                        ),
                      ],
                    ),
                    child: StoredImage(
                      filePath: 'logo/$logo.png',
                      colorBlendMode: BlendMode.modulate,
                      color: const Color.fromARGB(150, 255, 255, 255),
                      imageUrl: ghLogoLink,
                      scale: 2.5,
                      placeholder: Image.asset(
                        'assets/placeholders/logo.png',
                        colorBlendMode: BlendMode.modulate,
                        color: Colors.transparent,
                        scale: 2.5,
                      ),
                    ),
                  ),
                )
              : const SizedBox.shrink(),
          Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Transform(
                            transform: Matrix4.translationValues(-20, 10, -1)..rotateZ(-0.088),
                            child: Container(
                              padding: const EdgeInsets.all(0.0),
                              margin: const EdgeInsets.all(10.0),
                              decoration: BoxDecoration(
                                boxShadow: const <BoxShadow>[
                                  BoxShadow(
                                    color: Color.fromRGBO(0, 0, 0, 0.5),
                                    offset: Offset(0, 8.0),
                                    blurRadius: 10.0,
                                  ),
                                ],
                                border: Border.all(
                                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                                  width: 4.0,
                                  style: BorderStyle.solid,
                                ),
                              ),
                              child: StoredImage(
                                colorBlendMode: BlendMode.modulate,
                                color: const Color.fromARGB(99, 255, 255, 255),
                                scale: 0.9,
                                fit: BoxFit.fitWidth,
                                placeholder: Image.asset(
                                  'assets/placeholders/avatar.png',
                                  colorBlendMode: BlendMode.modulate,
                                  color: Colors.transparent,
                                  scale: 0.9,
                                  fit: BoxFit.fitWidth,
                                ),
                                imageUrl: ghAvatarLink,
                                filePath:
                                    'images/${operator.id}_dl${DisplayList.avatar.index.toString()}.png',
                              ),
                            ),
                          ),
                          Transform(
                            transform: Matrix4.rotationZ(0.0),
                            child: Container(
                              padding: const EdgeInsets.all(0.0),
                              margin: const EdgeInsets.all(10.0),
                              decoration: BoxDecoration(
                                boxShadow: const <BoxShadow>[
                                  BoxShadow(
                                    color: Color.fromRGBO(0, 0, 0, 0.5),
                                    offset: Offset(0, 8.0),
                                    blurRadius: 10.0,
                                  ),
                                ],
                                border: Border.all(
                                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                                  width: 4.0,
                                  style: BorderStyle.solid,
                                ),
                                color: const Color.fromARGB(255, 241, 241, 241),
                              ),
                              child: StoredImage(
                                heroTag: operator.id,
                                filePath:
                                    'images/${operator.id}_dl${DisplayList.avatar.index.toString()}.png',
                                fit: BoxFit.fitWidth,
                                placeholder: Image.asset(
                                  'assets/placeholders/avatar.png',
                                  colorBlendMode: BlendMode.modulate,
                                  color: Colors.transparent,
                                  fit: BoxFit.fitWidth,
                                ),
                                imageUrl: ghAvatarLink,
                                useSync: true,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const Expanded(child: SizedBox()),
                ],
              ),
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: '[${operator.displayNumber} / ${operator.id}]\n',
                        style: TextStyle(
                          color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.5),
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                      TextSpan(text: operator.itemUsage),
                      TextSpan(
                        text: '\n${operator.itemDesc}',
                        style: const TextStyle(fontStyle: FontStyle.italic),
                      ),
                    ],
                  ),
                ),
              ),
              Wrap(
                spacing: 8.0,
                children: List.generate(operator.tagList.length + 3, (index) {
                  if (index == 0) {
                    return ActionChip(
                      label: Text(operator.professionString),
                      avatar: Image.asset(professionStr),
                      backgroundColor: Theme.of(context).brightness == Brightness.light
                          ? Theme.of(context).colorScheme.primary.withOpacity(0.85)
                          : null,
                      labelStyle: Theme.of(context).brightness == Brightness.light
                          ? const TextStyle(color: Colors.white)
                          : null,
                      onPressed: () {},
                    );
                  }
                  if (index == 1) {
                    return ActionChip(
                      label: Text(operator.subProfessionString),
                      avatar: Image.asset(subprofessionStr),
                      backgroundColor: Theme.of(context).brightness == Brightness.light
                          ? Theme.of(context).colorScheme.primary.withOpacity(0.7)
                          : null,
                      labelStyle: Theme.of(context).brightness == Brightness.light
                          ? const TextStyle(color: Colors.white)
                          : null,
                      onPressed: () {},
                    );
                  }
                  if (index == 2) {
                    return ActionChip(
                      label: Text(operator.position.toLowerCase().capitalize()),
                      side: BorderSide(
                        color: operator.position == 'RANGED'
                            ? StaticColors.fromBrightness(context).yellow
                            : StaticColors.fromBrightness(context).red,
                      ),
                      onPressed: () {},
                    );
                  }
                  return ActionChip(
                    label: Text(operator.tagList[index - 3]),
                    side: BorderSide(
                      color: Theme.of(context).colorScheme.tertiary,
                    ),
                    onPressed: () {},
                  );
                }),
              ),
              AnimatedSize(
                duration: const Duration(milliseconds: 250),
                curve: Curves.ease,
                child: relatedOps,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
