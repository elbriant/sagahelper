import 'package:flutter/material.dart';
import 'package:sagahelper/components/recruitment/recruit_operator_container.dart';
import 'package:sagahelper/models/recruit_combo.dart';
import 'package:sagahelper/providers/tools/recruitment/recruit_tag_map_provider.dart';

class RecruitComboContainer extends StatelessWidget {
  final RecruitCombo combo;
  final Map<int, RecruitTagInfo> tagMap;

  const RecruitComboContainer({
    super.key,
    required this.combo,
    required this.tagMap,
  });

  @override
  Widget build(BuildContext context) {
    final tagNames = combo.tagIds
        .map((id) => tagMap[id]?.tagName)
        .whereType<String>()
        .toList();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest.withAlpha(120),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.outlineVariant.withAlpha(80),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Tags header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer.withAlpha(60),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            ),
            child: Wrap(
              spacing: 6,
              runSpacing: 4,
              children: tagNames.map((name) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary.withAlpha(30),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: Theme.of(context).colorScheme.primary.withAlpha(80),
                    ),
                  ),
                  child: Text(
                    name,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          // Operator grid
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: combo.matches.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                childAspectRatio: 1.0,
                mainAxisSpacing: 2,
                crossAxisSpacing: 2,
              ),
              itemBuilder: (context, index) {
                return RecruitOperatorContainer(
                  recruitOp: combo.matches[index],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
