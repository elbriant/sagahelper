import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:sagahelper/components/filter_tile.dart';
import 'package:sagahelper/providers/tools/recruitment/recruit_selected_tags_provider.dart';
import 'package:sagahelper/providers/tools/recruitment/recruit_tag_map_provider.dart';

class RecruitTagsBottomSheet extends ConsumerWidget {
  const RecruitTagsBottomSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tagMapAsync = ref.watch(recruitTagMapProvider);
    final selectedTags = ref.watch(recruitSelectedTagsProvider);

    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header with count and clear button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Text(
                  'Select Tags',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const Spacer(),
                if (selectedTags.isNotEmpty)
                  TextButton.icon(
                    onPressed: () => ref.read(recruitSelectedTagsProvider.notifier).reset(),
                    icon: const Icon(Icons.refresh, size: 18),
                    label: const Text('Reset'),
                  ),
              ],
            ),
          ),
          // Selected tags preview (max 3)
          if (selectedTags.isNotEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: _SelectedTagsPreview(
                selectedTags: selectedTags,
                tagMapAsync: tagMapAsync,
              ),
            ),
          const Divider(height: 1),
          // Tag lists
          Flexible(
            child: tagMapAsync.when(
              data: (tagMap) => _buildTagList(context, ref, tagMap, selectedTags),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Error: $e')),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTagList(
    BuildContext context,
    WidgetRef ref,
    Map<int, RecruitTagInfo> tagMap,
    RecruitSelectedTags selectedTags,
  ) {
    // Group tags by category
    final grouped = <String, List<RecruitTagInfo>>{};
    for (final tag in tagMap.values) {
      final cat = tag.tagCat ?? 'Others';
      grouped.putIfAbsent(cat, () => []).add(tag);
    }

    // Sort Others alphabetically
    grouped['Others']?.sort((a, b) => a.tagName.compareTo(b.tagName));

    // Define display order
    const categoryOrder = ['Rarity', 'Class', 'Position', 'Others'];

    return Column(
      children: [
        for (final category in categoryOrder) ...[
          if (grouped.containsKey(category))
            FilterTile(
              title: category,
              initiallyExpanded: true,
              child: Wrap(
                spacing: 6.0,
                runSpacing: 4.0,
                children: grouped[category]!.map((tag) {
                  final isSelected = selectedTags.selectedTagIds.contains(tag.tagId);
                  return FilterChip(
                    label: Text(tag.tagName),
                    selected: isSelected,
                    onSelected: (_) {
                      ref.read(recruitSelectedTagsProvider.notifier).toggleTag(tag.tagId);
                    },
                    showCheckmark: false,
                  );
                }).toList(),
              ),
            ),
        ],
        const SizedBox(height: 16),
      ],
    );
  }
}

class _SelectedTagsPreview extends ConsumerWidget {
  final RecruitSelectedTags selectedTags;
  final AsyncValue<Map<int, RecruitTagInfo>> tagMapAsync;

  const _SelectedTagsPreview({
    required this.selectedTags,
    required this.tagMapAsync,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tagNames = tagMapAsync.whenOrNull(
          data: (tagMap) => selectedTags.tagStack
              .map((id) => tagMap[id]?.tagName)
              .whereType<String>()
              .toList(),
        ) ??
        [];

    final displayCount = tagNames.length.clamp(0, 3);
    final remaining = tagNames.length - displayCount;

    return Row(
      children: [
        // Tag chips
        Expanded(
          child: Wrap(
            spacing: 6,
            runSpacing: 4,
            children: [
              for (int i = 0; i < displayCount; i++)
                _TagChip(
                  label: tagNames[i],
                  onRemove: () {
                    final tagId = selectedTags.tagStack[i];
                    ref.read(recruitSelectedTagsProvider.notifier).toggleTag(tagId);
                  },
                ),
              if (remaining > 0)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    '+$remaining more',
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _TagChip extends StatelessWidget {
  final String label;
  final VoidCallback onRemove;

  const _TagChip({
    required this.label,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(left: 8, right: 2),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onPrimaryContainer,
            ),
          ),
          GestureDetector(
            onTap: onRemove,
            child: Padding(
              padding: const EdgeInsets.only(left: 2, right: 4, top: 2, bottom: 2),
              child: Icon(
                Icons.close,
                size: 14,
                color: Theme.of(context).colorScheme.onPrimaryContainer,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
