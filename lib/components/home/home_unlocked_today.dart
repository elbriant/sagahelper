import 'package:flutter/material.dart';
import 'package:gradient_borders/box_borders/gradient_box_border.dart';
import 'package:provider/provider.dart';
import 'package:sagahelper/components/home/home_title.dart';
import 'package:sagahelper/components/popup_dialog.dart';
import 'package:sagahelper/providers/cache_provider.dart';
import 'package:sagahelper/providers/styles_provider.dart';
import 'package:sagahelper/utils/extensions.dart';
import 'package:styled_text/styled_text.dart';

const List<MapEntry<String, Map<String, dynamic>>> stages = [
  MapEntry("weekly_1", {
    "name": "Solid Defense",
    "desc":
        "A mission to acquire the materials needed for the Promotion of Defender and Medic Operators.\nThe battle will be easier if you employ Defender and Medic Operators well.\n<@lv.item><Poison Haze></> Operators lose HP constantly.",
    "days": [
      1,
      4,
      5,
      7,
    ],
  }),
  MapEntry("weekly_2", {
    "name": "Fierce Attack",
    "desc":
        "A mission to acquire the materials needed for the Promotion of Sniper and Caster Operators.\nThe battle will be easier if you employ Sniper and Caster Operators well.\n<@lv.item><Anti-air Rune></>Operators deployed on it will attack a bit more slowly but their ATK against aerial units will be increased significantly.",
    "days": [
      1,
      2,
      5,
      6,
    ],
  }),
  MapEntry("weekly_3", {
    "name": "Unstoppable Charge",
    "desc":
        "A mission to acquire the materials needed for the Promotion of Vanguard and Supporter Operators.\nThe battle will be easier if you employ Vanguard and Supporter Operators well.\n<@lv.item><Medical Rune></> Operators deployed on it enjoy constant healing.",
    "days": [
      3,
      4,
      6,
      7,
    ],
  }),
  MapEntry("weekly_4", {
    "name": "Fearless Protection",
    "desc":
        "A mission to acquire the materials needed for the Promotion of Guard and Specialist Operators.\nThe battle will be easier if you employ Guard and Specialist Operators well.",
    "days": [
      2,
      3,
      6,
      7,
    ],
  }),
  MapEntry("weekly_5", {
    "name": "Tough Siege",
    "desc":
        "Defend against enemies in a hostile environment.\n<@lv.item><Poison Haze></> Operators lose HP constantly",
    "days": [
      1,
      4,
      6,
      7,
    ],
  }),
  MapEntry("weekly_6", {
    "name": "Aerial Threat",
    "desc":
        "Defend against the enemy's aerial units.\n<@lv.rem>Melee Operators cannot be deployed.</>",
    "days": [
      2,
      3,
      5,
      7,
    ],
  }),
  MapEntry("weekly_7", {
    "name": "Tactical Drill",
    "desc":
        "Defend against the enemy's surprise attack.\n<@lv.rem>Deployment Points will not automatically recover in this operation; You get 1 Deployment Point upon killing 1 enemy.</>",
    "days": [
      1,
      2,
      3,
      4,
      5,
      6,
      7,
    ],
  }),
  MapEntry("weekly_8", {
    "name": "Resource Search",
    "desc": "Defend against enemies with high DEF.",
    "days": [
      1,
      3,
      5,
      6,
    ],
  }),
  MapEntry("weekly_9", {
    "name": "Cargo Escort",
    "desc":
        "Defend against enemies in a flexible way.\n<@lv.rem>The recovery speed of Deployment Points is slow in this operation, but deployment is not limited to melee and ranged cells.</>",
    "days": [
      2,
      4,
      6,
      7,
    ],
  }),
];

class HomeUnlockedToday extends StatelessWidget {
  const HomeUnlockedToday({
    super.key,
    required this.serverTime,
  });

  final DateTime serverTime;

  bool getSpecialOpen(Map<String, dynamic>? stageTable) {
    if (stageTable == null) return false;
    bool isCurrentlyActive = false;

    Map epoch = (stageTable["forceOpenTable"] as Map).values.last;

    if (serverTime.isAfter(DateTime.fromMillisecondsSinceEpoch(epoch["startTime"] * 1000)) &&
        serverTime.isBefore(DateTime.fromMillisecondsSinceEpoch(epoch["endTime"] * 1000))) {
      isCurrentlyActive = true;
    }

    return isCurrentlyActive;
  }

  @override
  Widget build(BuildContext context) {
    final stageTable =
        context.select<CacheProvider, Map<String, dynamic>?>((p) => p.cachedStageTable);
    final bool specialOpen = getSpecialOpen(stageTable);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 8.0),
        const HomeTitle(
          label: 'Open Today',
        ),
        if (specialOpen)
          SizedBox(
            width: double.maxFinite,
            child: Text(
              "There's special event making all supply stages open",
              style: TextStyle(
                color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
              ),
              textScaler: const TextScaler.linear(0.75),
            ),
          ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2.0, vertical: 8.0),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Material(
              child: Row(
                spacing: 8,
                children: List.generate(stages.length, (index) {
                  if (!(stages[index].value["days"] as List<int>).contains(serverTime.weekday) &&
                      !specialOpen) {
                    return null;
                  }

                  return _StageCards(
                    weekly: stages[index],
                    speciallyOpen: specialOpen,
                  );
                }).nullParser(),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _StageCards extends StatelessWidget {
  const _StageCards({required this.weekly, required this.speciallyOpen});

  final MapEntry weekly;
  final bool speciallyOpen;

  @override
  Widget build(BuildContext context) {
    return Ink(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: speciallyOpen
            ? const GradientBoxBorder(
                gradient: LinearGradient(
                  colors: [Color.fromARGB(190, 255, 227, 89), Color.fromARGB(190, 255, 168, 81)],
                  stops: [0, 1],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              )
            : Border.all(
                color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.40),
                strokeAlign: BorderSide.strokeAlignOutside,
              ),
        color: Theme.of(context).colorScheme.primaryContainer,
        image: DecorationImage(
          image: AssetImage('assets/supply_stages/${weekly.key}-min.png'),
          fit: BoxFit.none,
          scale: 2,
          alignment: const Alignment(0, -0.25),
          colorFilter:
              const ColorFilter.mode(Color.fromARGB(236, 228, 228, 228), BlendMode.modulate),
        ),
      ),
      child: InkWell(
        onTap: () => PopupDialog.normal(
          context: context,
          title: Text(weekly.value["name"]),
          content: StyledText(
            text: (weekly.value["desc"] as String).akRichTextParser(),
            tags: context.read<StyleProvider>().tagsAsArknights(context: context),
          ),
        ),
        borderRadius: BorderRadius.circular(6),
        child: SizedBox(
          width: 64,
          height: 172,
          child: Center(
            child: Text(
              weekly.value["name"],
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                shadows: [
                  Shadow(blurRadius: 2.0),
                  Shadow(blurRadius: 2.0),
                  Shadow(blurRadius: 2.0),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
