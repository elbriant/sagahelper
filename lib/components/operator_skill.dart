import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sagahelper/components/range_tile.dart';
import 'package:sagahelper/components/slider_selector.dart';
import 'package:sagahelper/components/stored_image.dart';
import 'package:sagahelper/components/styled_buttons.dart';
import 'package:sagahelper/global_data.dart';
import 'package:sagahelper/models/operator.dart';
import 'package:sagahelper/providers/settings_provider.dart';
import 'package:sagahelper/providers/styles_provider.dart';
import 'package:sagahelper/utils/extensions.dart';
import 'package:styled_text/styled_text.dart';

class OperatorSkill extends StatelessWidget {
  const OperatorSkill({
    super.key,
    required this.operator,
    required this.skillsDetails,
    required this.currentSelectedSkill,
    required this.currentSkillLevel,
    required this.onSkillSelectedSetter,
    required this.onSkillLevelChanged,
  });

  final Operator operator;
  final List<Map<String, dynamic>> skillsDetails;
  final int currentSkillLevel;
  final int currentSelectedSkill;

  final ValueSetter<int> onSkillSelectedSetter;
  final ValueSetter<int> onSkillLevelChanged;

  @override
  Widget build(BuildContext context) {
    Map selectedSkillDetailLv = skillsDetails[currentSelectedSkill]["levels"][currentSkillLevel];
    Map selectedSkillDetail = skillsDetails[currentSelectedSkill];
    Map selectedSkill = operator.skills[currentSelectedSkill];

    List<Widget> skillSlots = List.generate(3, (index) {
      if (operator.skills.elementAtOrNull(index) != null) {
        bool selected = currentSelectedSkill == index;

        return Container(
          decoration: BoxDecoration(
            color: selected
                ? Theme.of(context).colorScheme.surfaceContainerHighest
                : Theme.of(context).colorScheme.surfaceContainerHigh,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(8.0)),
          ),
          child: SizedBox.square(
            dimension: 128 / 2,
            child: Stack(
              children: [
                Positioned.fill(
                  top: -20,
                  child: Text(
                    (index + 1).toString(),
                    textScaler: const TextScaler.linear(5),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.1),
                    ),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.all(12.0),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: selected
                          ? Theme.of(context).colorScheme.inverseSurface
                          : Theme.of(context).colorScheme.inverseSurface.withOpacity(0.7),
                      width: 1.0,
                      strokeAlign: BorderSide.strokeAlignOutside,
                    ),
                    borderRadius: BorderRadius.circular(4.0),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4.0),
                    child: StoredImage(
                      imageUrl:
                          '$kSkillRepo/skill_icon_${skillsDetails[index]["iconId"] ?? skillsDetails[index]["skillId"]}.png'
                              .githubEncode(),
                      filePath:
                          'skillicon/${skillsDetails[index]["iconId"] ?? skillsDetails[index]["skillId"]}.png',
                      color: !selected ? const Color.fromARGB(255, 134, 134, 134) : null,
                      colorBlendMode: BlendMode.modulate,
                    ),
                  ),
                ),
                Positioned.fill(
                  child: Material(
                    type: MaterialType.transparency,
                    child: InkWell(
                      onTap: () {
                        if (selected) return;
                        onSkillSelectedSetter.call(index);
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      } else {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainer,
          ),
          child: const SizedBox.square(dimension: 128 / 2),
        );
      }
    });

    List<Widget> extraSlots = [
      selectedSkillDetailLv["rangeId"] != null
          ? RangeTile.smol(selectedSkillDetailLv["rangeId"])
          : null,
      selectedSkill["overrideTokenKey"] != null ? Text(selectedSkill["overrideTokenKey"]) : null,
    ].nullParser();

    List<Widget> dataWidgets() {
      List<Widget?> widgets = [];
      final EdgeInsets lPadding = const EdgeInsets.all(2.0);
      final EdgeInsets lRightPadding = const EdgeInsets.only(right: 6.0);
      final double textScale = 0.8;

      // skill sp data
      widgets.add(
        switch (selectedSkillDetailLv["spData"]["spType"]) {
          "INCREASE_WITH_TIME" => Container(
              height: 40,
              width: 72,
              margin: lRightPadding,
              decoration: BoxDecoration(
                color: StaticColors.fromBrightness(context).green,
                borderRadius: BorderRadius.circular(8.0),
                border: Border.all(
                  color: StaticColors.fromBrightness(context).green,
                  strokeAlign: BorderSide.strokeAlignInside,
                  width: 2.0,
                ),
              ),
              padding: lPadding,
              child: Text(
                'Per Second Recovery',
                softWrap: true,
                textAlign: TextAlign.center,
                textScaler: TextScaler.linear(textScale),
                style: TextStyle(
                  color: StaticColors.fromBrightness(context).onGreen,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          "INCREASE_WHEN_ATTACK" => Container(
              height: 40,
              width: 72,
              margin: lRightPadding,
              decoration: BoxDecoration(
                color: StaticColors.fromBrightness(context).orange,
                borderRadius: BorderRadius.circular(8.0),
                border: Border.all(
                  color: StaticColors.fromBrightness(context).orange,
                  strokeAlign: BorderSide.strokeAlignInside,
                  width: 2.0,
                ),
              ),
              padding: lPadding,
              child: Text(
                'Offensive Recovery',
                softWrap: true,
                textAlign: TextAlign.center,
                textScaler: TextScaler.linear(textScale),
                style: TextStyle(
                  color: StaticColors.fromBrightness(context).onOrange,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          "INCREASE_WHEN_TAKEN_DAMAGE" => Container(
              height: 40,
              width: 72,
              margin: lRightPadding,
              decoration: BoxDecoration(
                color: StaticColors.fromBrightness(context).yellow,
                borderRadius: BorderRadius.circular(8.0),
                border: Border.all(
                  color: StaticColors.fromBrightness(context).yellow,
                  strokeAlign: BorderSide.strokeAlignInside,
                  width: 2.0,
                ),
              ),
              padding: lPadding,
              child: Text(
                'Deffensive Recovery',
                softWrap: true,
                textAlign: TextAlign.center,
                textScaler: TextScaler.linear(textScale),
                style: TextStyle(
                  color: StaticColors.fromBrightness(context).onYellow,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          _ => null,
        },
      );

      // skill activation type
      widgets.add(
        switch (selectedSkillDetailLv["skillType"]) {
          "MANUAL" => Container(
              height: 40,
              width: 72,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainer,
                borderRadius: BorderRadius.circular(8.0),
                border: Border.all(
                  color: Theme.of(context).colorScheme.outline,
                  strokeAlign: BorderSide.strokeAlignInside,
                  width: 2.0,
                ),
              ),
              padding: lPadding,
              child: Text(
                'Manual Trigger',
                softWrap: true,
                textAlign: TextAlign.center,
                textScaler: TextScaler.linear(textScale),
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          "AUTO" => Container(
              height: 40,
              width: 72,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.inverseSurface,
                borderRadius: BorderRadius.circular(8.0),
                border: Border.all(
                  color: Theme.of(context).colorScheme.outline,
                  strokeAlign: BorderSide.strokeAlignInside,
                  width: 2.0,
                ),
              ),
              padding: lPadding,
              child: Text(
                'Auto Trigger',
                softWrap: true,
                textAlign: TextAlign.center,
                textScaler: TextScaler.linear(textScale),
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onInverseSurface,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          "PASSIVE" => Container(
              height: 40,
              width: 72,
              decoration: BoxDecoration(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(8.0),
                border: Border.all(
                  color: Theme.of(context).colorScheme.outline,
                  strokeAlign: BorderSide.strokeAlignInside,
                  width: 2.0,
                ),
              ),
              padding: lPadding,
              child: Center(
                child: Text(
                  'Passive',
                  softWrap: true,
                  textAlign: TextAlign.center,
                  textScaler: TextScaler.linear(textScale),
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.outline,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          _ => null,
        },
      );
      return widgets.nullParser();
    }

    List<Widget> lilDataWidgets() {
      List<Widget?> widgets = [];

      final Color textColor = Theme.of(context).colorScheme.onSecondary;
      final Color contrastColor = Theme.of(context).colorScheme.secondary;

      // skill cost
      widgets.add(
        DiffChip(
          icon: Icons.bolt,
          label: 'SP Cost',
          value: (skillsDetails[currentSelectedSkill]["levels"][currentSkillLevel]["spData"]
                  ["spCost"] as int)
              .toString(),
          color: textColor,
          backgroundColor: contrastColor,
          axis: currentSkillLevel == 0
              ? AxisDirection.left
              : Calc.valueDifference(
                  skillsDetails[currentSelectedSkill]["levels"][currentSkillLevel]["spData"]
                      ["spCost"],
                  skillsDetails[currentSelectedSkill]["levels"][currentSkillLevel - 1]["spData"]
                      ["spCost"],
                ),
        ),
      );

      // skill initial sp
      widgets.add(
        DiffChip(
          icon: Icons.play_arrow,
          label: 'Initial SP',
          value: (skillsDetails[currentSelectedSkill]["levels"][currentSkillLevel]["spData"]
                  ["initSp"] as int)
              .toString(),
          color: textColor,
          backgroundColor: contrastColor,
          axis: currentSkillLevel == 0
              ? AxisDirection.left
              : Calc.valueDifference(
                  skillsDetails[currentSelectedSkill]["levels"][currentSkillLevel]["spData"]
                      ["initSp"],
                  skillsDetails[currentSelectedSkill]["levels"][currentSkillLevel - 1]["spData"]
                      ["initSp"],
                ),
        ),
      );

      // skill duration
      widgets.add(
        switch ((selectedSkillDetailLv["durationType"] as String)) {
          "NONE" => (selectedSkillDetailLv["duration"] > 0.0)
              ? DiffChip(
                  icon: Icons.timelapse,
                  label: 'Duration',
                  value: (skillsDetails[currentSelectedSkill]["levels"][currentSkillLevel]
                          ["duration"] as double)
                      .toStringAsFixed(3)
                      .replaceFirst(RegExp(r'\.?0*$'), ''),
                  color: textColor,
                  backgroundColor: contrastColor,
                  axis: currentSkillLevel == 0
                      ? AxisDirection.left
                      : Calc.valueDifference(
                          skillsDetails[currentSelectedSkill]["levels"][currentSkillLevel]
                              ["duration"],
                          skillsDetails[currentSelectedSkill]["levels"][currentSkillLevel - 1]
                              ["duration"],
                        ),
                )
              : null,
          "AMMO" => ((skillsDetails[currentSelectedSkill]["levels"][currentSkillLevel]["blackboard"]
                          as List)
                      .lastWhere(
                    (i) => ((i as Map)["key"] as String).endsWith("trigger_time"),
                    orElse: () => null,
                  ) !=
                  null)
              ? DiffChip(
                  icon: Icons.stacked_bar_chart,
                  label: 'Ammo',
                  value: (((skillsDetails[currentSelectedSkill]["levels"][currentSkillLevel]
                              ["blackboard"] as List)
                          .lastWhere(
                    (i) => ((i as Map)["key"] as String).endsWith("trigger_time"),
                  ) as Map)["value"] as double)
                      .toStringAsFixed(3)
                      .replaceFirst(RegExp(r'\.?0*$'), ''),
                  color: textColor,
                  backgroundColor: contrastColor,
                  axis: currentSkillLevel == 0
                      ? AxisDirection.left
                      : Calc.valueDifference(
                          ((skillsDetails[currentSelectedSkill]["levels"][currentSkillLevel]
                                  ["blackboard"] as List)
                              .lastWhere(
                            (i) => ((i as Map)["key"] as String).endsWith("trigger_time"),
                          ) as Map)["value"],
                          ((skillsDetails[currentSelectedSkill]["levels"][currentSkillLevel - 1]
                                  ["blackboard"] as List)
                              .lastWhere(
                            (i) => ((i as Map)["key"] as String).endsWith("trigger_time"),
                          ) as Map)["value"],
                        ),
                )
              : null,
          _ => null,
        },
      );

      return widgets.nullParser();
    }

    List<Widget> metadata() {
      List<Widget> widgets = [];

      final Color textColor = Colors.white60;
      final Color contrastColor = Colors.grey[800]!;

      // skill cost
      for (Map metadata in selectedSkillDetailLv["blackboard"]) {
        int index =
            (skillsDetails[currentSelectedSkill]["levels"][currentSkillLevel]["blackboard"] as List)
                .indexOf(metadata);

        widgets.add(
          DiffChip(
            label: metadata["key"],
            value: metadata["valueStr"] ?? (metadata["value"] as double).toStringWithPrecision(),
            color: textColor,
            backgroundColor: contrastColor,
            axis: currentSkillLevel == 0
                ? AxisDirection.left
                : Calc.valueDifference(
                    skillsDetails[currentSelectedSkill]["levels"][currentSkillLevel]["blackboard"]
                        [index]["value"],
                    skillsDetails[currentSelectedSkill]["levels"][currentSkillLevel - 1]
                        ["blackboard"][index]["value"],
                  ),
          ),
        );
      }

      return widgets;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: skillSlots,
        ),
        Container(
          padding: const EdgeInsets.all(8.0),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.only(
              bottomLeft: const Radius.circular(8.0),
              bottomRight: const Radius.circular(8.0),
              topRight: operator.skills.length < 3 ? const Radius.circular(8.0) : Radius.zero,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          selectedSkillDetailLv["name"],
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.w800,
                          ),
                          textScaler: TextScaler.linear(
                            ((18.0 / (selectedSkillDetailLv["name"] as String).length.toDouble()) -
                                    0.2)
                                .clamp(1.3, 1.9),
                          ),
                        ),
                        const SizedBox(height: 4.0),
                        Row(
                          children: dataWidgets(),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(6.0),
                      border: Border.all(
                        color: Theme.of(context).colorScheme.outline,
                      ),
                    ),
                    width: 90,
                    height: 90,
                    child: Column(
                      children: [
                        SliderSelector(
                          length: (selectedSkillDetail["levels"] as List).length,
                          currentIndex: currentSkillLevel,
                          onValueChanged: onSkillLevelChanged,
                          builder: (index, context) {
                            String label =
                                (index < 7) ? (index + 1).toString() : "M${(index - 6).toString()}";
                            return (index < 7)
                                ? Text(
                                    label,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      shadows: [
                                        Shadow(
                                          offset: Offset.zero,
                                          blurRadius: 1.0,
                                        ),
                                      ],
                                    ),
                                    textScaler: const TextScaler.linear(2),
                                  )
                                : Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      Image.asset(
                                        'assets/masteries/specialized_${index - 6}_small.png',
                                      ),
                                      Text(
                                        label,
                                        style: const TextStyle(
                                          shadows: [
                                            Shadow(
                                              offset: Offset.zero,
                                              blurRadius: 3.0,
                                            ),
                                          ],
                                        ),
                                        textScaler: const TextScaler.linear(1.2),
                                      ),
                                    ],
                                  );
                          },
                        ),
                        const Text('Skill Level'),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6.0),
              Wrap(
                runSpacing: 10.0,
                spacing: 6.0,
                children: lilDataWidgets(),
              ),
              const SizedBox(height: 6.0),
              AnimatedSize(
                duration: const Duration(milliseconds: 250),
                curve: Curves.ease,
                child: StyledText(
                  text: (selectedSkillDetailLv["description"] as String)
                      .akRichTextParser()
                      .varParser(selectedSkillDetailLv["blackboard"]),
                  tags: context.read<StyleProvider>().tagsAsArknights(context: context),
                  async: true,
                ),
              ),
              AnimatedSize(
                duration: const Duration(milliseconds: 250),
                curve: Curves.ease,
                child: SizedBox(
                  child: context.watch<SettingsProvider>().prefs[PrefsFlags.menuShowAdvanced]
                      ? Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Wrap(
                            spacing: 6.0,
                            runSpacing: 3.0,
                            children: metadata(),
                          ),
                        )
                      : null,
                ),
              ),
              AnimatedSize(
                duration: const Duration(milliseconds: 250),
                curve: Curves.ease,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: extraSlots,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
