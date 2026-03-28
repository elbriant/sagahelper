import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sagahelper/components/stored_image.dart';
import 'package:sagahelper/core/asset_service.dart';
import 'package:sagahelper/core/global_data.dart';
import 'package:sagahelper/models/config/local_data_manager.dart';
import 'package:sagahelper/models/config/types.dart';
import 'package:sagahelper/models/filters.dart';
import 'package:sagahelper/models/operator.dart';
import 'package:sagahelper/providers/style_provider.dart';
import 'package:sagahelper/utils/extensions.dart';

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

  /// my lazy ass didnt lowercased when uploading on the api again 😩
  final Map<String, String> logoNameExceptions = {
    "laterano": "Laterano",
    "leithanien": "Leithanien",
  };

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
    final networkSubProfessionStr =
        "$kSubProfessionIconRepo/sub_${widget.operator.subProfessionId.toLowerCase()}_icon.png"
            .githubEncode();

    final String ghAvatarLink = '$kAvatarRepo/${widget.operator.id}.png'.githubEncode();
    String? logo = widget.operator.teamId ?? widget.operator.groupId ?? widget.operator.nationId;
    if (logoNameExceptions.containsKey(logo)) logo = logoNameExceptions[logo];
    final String ghLogoLink = '$kLogoRepo/logo_$logo.png'.githubEncode();

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
                    child: StoredCustomImage(
                      filename: '$logo.png',
                      imageUrl: ghLogoLink,
                      type: CacheType.operatorLogo,
                      scale: 2.5,
                      color: const Color.fromARGB(150, 255, 255, 255),
                      colorBlendMode: BlendMode.modulate,
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
                              child: StoredCustomImage(
                                colorBlendMode: BlendMode.modulate,
                                color: const Color.fromARGB(99, 255, 255, 255),
                                scale: 0.9,
                                fit: BoxFit.fitWidth,
                                placeholderColorBlendMode: BlendMode.modulate,
                                placeholderColor: Colors.transparent,
                                placeholderFit: BoxFit.fitWidth,
                                placeholder: const AssetImage('assets/placeholders/avatar.png'),
                                imageUrl: ghAvatarLink,
                                type: CacheType.operatorAvatar,
                                filename:
                                    '${widget.operator.id}_dl${OperatorDisplayMode.avatar.index.toString()}.png',
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
                            child: Hero(
                              tag: widget.operator.id,
                              child: StoredCustomImage(
                                filename:
                                    '${widget.operator.id}_dl${OperatorDisplayMode.avatar.index.toString()}.png',
                                imageUrl: ghAvatarLink,
                                type: CacheType.operatorAvatar,
                                fit: BoxFit.fitWidth,
                                placeholder: const AssetImage('assets/placeholders/avatar.png'),
                                placeholderColor: Colors.transparent,
                                placeholderColorBlendMode: BlendMode.modulate,
                                placeholderFit: BoxFit.fitWidth,
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
                      avatar: AssetService.assetSet.contains(subprofessionStr)
                          ? Image.asset(subprofessionStr)
                          : StoredFadeInImage(
                              filename:
                                  "sub_${widget.operator.subProfessionId.toLowerCase()}_icon.png",
                              imageUrl: networkSubProfessionStr,
                            ),
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
                    return Consumer(
                      builder: (context, ref, child) {
                        final style = ref.watch(styleProvider).colors;
                        return ActionChip(
                          label: Text(widget.operator.position.toLowerCase().capitalize()),
                          side: BorderSide(
                            color: widget.operator.position == 'RANGED' ? style.yellow : style.red,
                          ),
                          onPressed: () => Navigator.of(context).pop(
                            FilterTag(
                              id: "${FilterType.position.prefix}_${widget.operator.position.toLowerCase()}",
                              key: widget.operator.position.toLowerCase(),
                              type: FilterType.position,
                            ),
                          ),
                        );
                      },
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
