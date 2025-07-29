import 'dart:io';

import 'package:flutter/material.dart';
import 'package:network_to_file_image/network_to_file_image.dart';
import 'package:sagahelper/components/stored_image.dart';
import 'package:sagahelper/global_data.dart';
import 'package:sagahelper/models/filters.dart';
import 'package:sagahelper/models/operator.dart';
import 'package:sagahelper/providers/settings_provider.dart';
import 'package:sagahelper/utils/extensions.dart';
import 'package:transparent_image/transparent_image.dart';

class OpinfoArchiveHeader extends StatefulWidget {
  const OpinfoArchiveHeader({super.key, required this.operator, required this.relatedOps});
  final Operator operator;
  final Widget relatedOps;

  static final photoTween = Matrix4Tween(
    begin: Matrix4.translationValues(0, 0, 0)..rotateZ(0),
    end: Matrix4.translationValues(-20, 10, -1)..rotateZ(-0.088),
  );

  @override
  State<OpinfoArchiveHeader> createState() => _OpinfoArchiveHeaderState();
}

class _OpinfoArchiveHeaderState extends State<OpinfoArchiveHeader>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    duration: const Duration(milliseconds: 350),
    vsync: this,
  );

  late final Animation<Matrix4> _animationTransform = OpinfoArchiveHeader.photoTween
      .animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));

  late final Future<File> _logoFile;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed((const Duration(milliseconds: 200)), () {
        if (mounted) {
          _controller.forward();
        }
      });
    });

    String? logo = widget.operator.teamId ?? widget.operator.groupId ?? widget.operator.nationId;
    if (logo == 'laterano' || logo == 'leithanien') {
      logo = logo?.replaceFirst('l', 'L');
    }

    _logoFile = LocalDataManager.localCacheFile('logo/$logo.png', true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final professionStr = 'assets/classes/class_${widget.operator.profession.toLowerCase()}.png';
    final subprofessionStr =
        'assets/subclasses/sub_${widget.operator.subProfessionId.toLowerCase()}_icon.png';

    final String ghAvatarLink = '$kAvatarRepo/${widget.operator.id}.png';
    String? logo = widget.operator.teamId ?? widget.operator.groupId ?? widget.operator.nationId;
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
                          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.25),
                          spreadRadius: 40,
                          blurRadius: 55,
                        ),
                      ],
                    ),
                    child: FutureBuilder(
                      future: _logoFile,
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) return const SizedBox.shrink();

                        return FadeInImage(
                          placeholder: MemoryImage(kTransparentImage),
                          image: NetworkToFileImage(
                            file: snapshot.data!,
                            url: ghLogoLink,
                            scale: 2.5,
                          ),
                          colorBlendMode: BlendMode.modulate,
                          color: const Color.fromARGB(150, 255, 255, 255),
                        );
                      },
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
                          AnimatedBuilder(
                            animation: _controller,
                            builder: (context, child) {
                              return Transform(
                                transform: _animationTransform.value,
                                child: child,
                              );
                            },
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
                                    'images/${widget.operator.id}_dl${DisplayList.avatar.index.toString()}.png',
                                useSync: false,
                                showProgress: false,
                              ),
                            ),
                          ),
                          Container(
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
                              heroTag: widget.operator.id,
                              filePath:
                                  'images/${widget.operator.id}_dl${DisplayList.avatar.index.toString()}.png',
                              fit: BoxFit.fitWidth,
                              placeholder: Image.asset(
                                'assets/placeholders/avatar.png',
                                colorBlendMode: BlendMode.modulate,
                                color: Colors.transparent,
                                fit: BoxFit.fitWidth,
                              ),
                              imageUrl: ghAvatarLink,
                              useSync: true,
                              showProgress: false,
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
                        text: '[${widget.operator.displayNumber} / ${widget.operator.id}]\n',
                        style: TextStyle(
                          color:
                              Theme.of(context).textTheme.bodySmall?.color?.withValues(alpha: 0.5),
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                      TextSpan(text: widget.operator.itemUsage),
                      TextSpan(
                        text: '\n${widget.operator.itemDesc}',
                        style: const TextStyle(fontStyle: FontStyle.italic),
                      ),
                    ],
                  ),
                ),
              ),
              Wrap(
                spacing: 8.0,
                children: List.generate(widget.operator.tagList.length + 3, (index) {
                  if (index == 0) {
                    return ActionChip(
                      label: Text(widget.operator.professionString),
                      avatar: Image.asset(professionStr),
                      backgroundColor: Theme.of(context).brightness == Brightness.light
                          ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.85)
                          : null,
                      labelStyle: Theme.of(context).brightness == Brightness.light
                          ? const TextStyle(color: Colors.white)
                          : null,
                      onPressed: () => Navigator.of(context).pop(
                        FilterTag(
                          id: "${FilterType.profession.prefix}_${widget.operator.profession.toLowerCase()}",
                          key: widget.operator.profession.toLowerCase(),
                          type: FilterType.profession,
                        ),
                      ),
                    );
                  }
                  if (index == 1) {
                    return ActionChip(
                      label: Text(widget.operator.subProfessionString),
                      avatar: Image.asset(subprofessionStr),
                      backgroundColor: Theme.of(context).brightness == Brightness.light
                          ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.7)
                          : null,
                      labelStyle: Theme.of(context).brightness == Brightness.light
                          ? const TextStyle(color: Colors.white)
                          : null,
                      onPressed: () => Navigator.of(context).pop(
                        FilterTag(
                          id: "${FilterType.subprofession.prefix}_${widget.operator.subProfessionId.toLowerCase()}",
                          key: widget.operator.subProfessionId.toLowerCase(),
                          type: FilterType.subprofession,
                        ),
                      ),
                    );
                  }
                  if (index == 2) {
                    return ActionChip(
                      label: Text(widget.operator.position.toLowerCase().capitalize()),
                      side: BorderSide(
                        color: widget.operator.position == 'RANGED'
                            ? StaticColors.fromBrightness(context).yellow
                            : StaticColors.fromBrightness(context).red,
                      ),
                      onPressed: () => Navigator.of(context).pop(
                        FilterTag(
                          id: "${FilterType.position.prefix}_${widget.operator.position.toLowerCase()}",
                          key: widget.operator.position.toLowerCase(),
                          type: FilterType.position,
                        ),
                      ),
                    );
                  }
                  return ActionChip(
                    label: Text(widget.operator.tagList[index - 3]),
                    side: BorderSide(
                      color: Theme.of(context).colorScheme.tertiary,
                    ),
                    onPressed: () => Navigator.of(context).pop(
                      FilterTag(
                        id: "${FilterType.tag.prefix}_${(widget.operator.tagList[index - 3] as String).toLowerCase()}",
                        key: (widget.operator.tagList[index - 3] as String).toLowerCase(),
                        type: FilterType.tag,
                      ),
                    ),
                  );
                }),
              ),
              AnimatedSize(
                duration: const Duration(milliseconds: 250),
                curve: Curves.ease,
                child: widget.relatedOps,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
