import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sagahelper/components/shimmer_loading_mask.dart';
import 'package:sagahelper/components/stored_image.dart';
import 'package:sagahelper/components/styled_buttons.dart';
import 'package:sagahelper/core/global_data.dart';
import 'package:sagahelper/models/operator.dart';
import 'package:sagahelper/providers/cache_provider.dart';
import 'package:sagahelper/providers/op_info_provider.dart';
import 'package:sagahelper/providers/styles_provider.dart';
import 'package:sagahelper/utils/extensions.dart';
import 'package:styled_text/styled_text.dart';

class OperatorBaseSkill extends StatefulWidget {
  const OperatorBaseSkill({
    super.key,
    required this.operator,
  });

  final Operator operator;

  @override
  State<OperatorBaseSkill> createState() => _OperatorBaseSkillState();
}

class _OperatorBaseSkillState extends State<OperatorBaseSkill> {
  int? localElite;
  int? localLevel;
  bool loaded = false;

  late final List<int> baseElites;
  late final List<int> baseLv;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (localElite != context.read<OpInfoProvider>().elite && localElite != null) {
      localElite = null;
    }

    if (localLevel != context.read<OpInfoProvider>().level.toInt() && localLevel != null) {
      localLevel = null;
    }
  }

  void loadData() async {
    List<int> elites = [];
    List<int> lvs = [];

    // purposely wait to not lag UI
    await Future.delayed(const Duration(milliseconds: 600));

    for (Map buff in widget.operator.baseSkills["buffChar"]) {
      for (Map buffdata in buff["buffData"]) {
        int thisBuffdataElite = int.parse(
          (buffdata["cond"]["phase"] as String).replaceFirst('PHASE_', ''),
        );
        if (!elites.contains(thisBuffdataElite)) elites.add(thisBuffdataElite);

        int thisBuffdataLv = buffdata["cond"]["level"];
        if (!lvs.contains(thisBuffdataLv)) lvs.add(thisBuffdataLv);
      }
    }
    elites.sort();
    lvs.sort();

    baseElites = elites;
    baseLv = lvs;

    if (mounted) {
      setState(() {
        loaded = true;
      });
    }
  }

  void setElite(int elite) {
    if (localElite == elite) return;
    setState(() {
      localElite = elite;
    });
  }

  void setLevel(int level) {
    if (localLevel == level) return;
    setState(() {
      localLevel = level;
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget child = const SizedBox.shrink();

    if (!loaded) {
      child = ShimmerLoadingMask(
        key: const Key('placeholder'),
        child: Container(
          margin: const EdgeInsets.only(top: 6.0, bottom: 18.0),
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(8.0),
          ),
          width: double.maxFinite,
          height: 200,
        ),
      );
    } else {
      final currentElite = context.select<OpInfoProvider, int>((p) => p.elite);
      final currentLevel = context.select<OpInfoProvider, double>((p) => p.level).toInt();

      int minElite = baseElites.lastWhere(
        (e) => e <= currentElite,
        orElse: () => baseElites.first,
      );
      int minLv = baseLv.lastWhere((e) => e <= currentLevel, orElse: () => baseLv.first);

      child = Container(
        key: const Key('baseskill'),
        width: double.maxFinite,
        padding: const EdgeInsets.all(24.0),
        margin: const EdgeInsets.only(bottom: 20.0),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainer,
          borderRadius: BorderRadius.circular(12.0),
        ),
        child: Column(
          children:
              List.generate(1 + (widget.operator.baseSkills["buffChar"] as List).length, (index) {
            if (index == 0) {
              return Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: List.generate(baseElites.length, (index) {
                      return LilButton(
                        selected: baseElites[index] == (localElite ?? minElite),
                        fun: () => setElite(baseElites[index]),
                        icon: ImageIcon(
                          AssetImage(
                            'assets/elite/elite_${baseElites[index]}.png',
                          ),
                        ),
                      );
                    }),
                  ),
                  Row(
                    children: List.generate(baseLv.length, (index) {
                      return LilButton(
                        selected: baseLv[index] == (localLevel ?? minLv),
                        fun: () => setLevel(baseLv[index]),
                        icon: Text.rich(
                          textScaler: const TextScaler.linear(0.8),
                          TextSpan(
                            children: [
                              const TextSpan(text: 'Lv', style: TextStyle(fontSize: 10)),
                              TextSpan(text: baseLv[index].toString()),
                            ],
                          ),
                        ),
                      );
                    }),
                  ),
                ],
              );
            } else {
              if ((widget.operator.baseSkills["buffChar"][index - 1]["buffData"] as List).isEmpty) {
                return null;
              }

              final Map? buffData =
                  (widget.operator.baseSkills["buffChar"][index - 1]["buffData"] as List).lastWhere(
                (buffdata) {
                  int thisBuffdataElite = int.parse(
                    (buffdata["cond"]["phase"] as String).replaceFirst('PHASE_', ''),
                  );
                  int thisBuffdataLv = buffdata["cond"]["level"];
                  return (localElite ?? minElite) >= thisBuffdataElite &&
                      (localLevel ?? minLv) >= thisBuffdataLv;
                },
                orElse: () => null,
              );

              final bool unlocked = (buffData != null);
              final String buffId =
                  (widget.operator.baseSkills["buffChar"][index - 1]["buffData"] as List).lastWhere(
                (buffdata) {
                  int thisBuffdataElite = int.parse(
                    (buffdata["cond"]["phase"] as String).replaceFirst('PHASE_', ''),
                  );
                  int thisBuffdataLv = buffdata["cond"]["level"];
                  return (localElite ?? minElite) >= thisBuffdataElite &&
                      (localLevel ?? minLv) >= thisBuffdataLv;
                },
                orElse: () =>
                    (widget.operator.baseSkills["buffChar"][index - 1]["buffData"] as List).first,
              )["buffId"];

              final int textelite = int.parse(
                ((widget.operator.baseSkills["buffChar"][index - 1]["buffData"] as List)
                        .first["cond"]["phase"] as String)
                    .replaceFirst('PHASE_', ''),
              );
              final int textlv =
                  (widget.operator.baseSkills["buffChar"][index - 1]["buffData"] as List)
                      .first["cond"]["level"];

              final cachedTable = context
                  .select<CacheProvider, Map<String, dynamic>>((p) => p.cachedBaseSkillTable!);

              final Color? bgColor =
                  unlocked ? (cachedTable[buffId]["buffColor"] as String).parseAsHex() : null;
              final Color textColor = unlocked
                  ? (cachedTable[buffId]["textColor"] as String).parseAsHex()
                  : Theme.of(context).colorScheme.onSurface;

              return Card.filled(
                margin: const EdgeInsets.only(top: 12.0),
                child: Container(
                  width: double.maxFinite,
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Stack(
                        children: [
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 150),
                            margin: const EdgeInsets.only(bottom: 8.0, top: 4.0),
                            decoration: BoxDecoration(
                              color: bgColor,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Theme.of(context).colorScheme.outline,
                              ),
                            ),
                            padding: EdgeInsets.only(
                              top: 2.0,
                              bottom: 2.0,
                              right: 12.0,
                              left: unlocked ? 35 : 12.0,
                            ),
                            child: Text(
                              (cachedTable[buffId]["buffName"] as String?) ?? '',
                              style: TextStyle(
                                color: textColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          Positioned(
                            left: 0,
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                color: bgColor,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: unlocked
                                      ? Theme.of(context).colorScheme.outline
                                      : Colors.transparent,
                                ),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(2.0),
                                child: StoredImage(
                                  colorBlendMode: BlendMode.modulate,
                                  imageUrl:
                                      '$kBaseSkillRepo/${cachedTable[buffId]["skillIcon"]}.png'
                                          .githubEncode(),
                                  filePath: 'baseicon/${cachedTable[buffId]["skillIcon"]}.png',
                                  scale: 1.3,
                                  color: unlocked ? null : Colors.transparent,
                                  placeholder: Image.asset(
                                    'assets/placeholders/baseskill.png',
                                    colorBlendMode: BlendMode.modulate,
                                    color: Colors.transparent,
                                    scale: 1.3,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      AnimatedSize(
                        duration: const Duration(milliseconds: 250),
                        curve: Curves.ease,
                        child: SizedBox(
                          width: double.maxFinite,
                          child: StyledText(
                            text: unlocked
                                ? ((cachedTable[buffId]["description"] ?? '') as String)
                                    .akRichTextParser()
                                : '<icon src="assets/sortIcon/lock.png"/> Unlocks at Elite ${textelite.toString()} lv${textlv.toString()}',
                            tags: context.read<StyleProvider>().tagsAsArknights(context: context),
                            textAlign: TextAlign.start,
                            async: true,
                          ),
                        ),
                      ),
                    ].nullParser(),
                  ),
                ),
              );
            }
          }).nullParser(),
        ),
      );
    }

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 150),
      child: child,
    );
  }
}
