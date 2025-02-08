import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sagahelper/components/filter_tile.dart';
import 'package:sagahelper/models/filters.dart';
import 'package:sagahelper/models/operator.dart';
import 'package:sagahelper/providers/cache_provider.dart';
import 'package:sagahelper/providers/settings_provider.dart';
import 'package:sagahelper/utils/extensions.dart';

const List<String> professionList = [
  'caster',
  'medic',
  'pioneer',
  'sniper',
  'special',
  'support',
  'tank',
  'warrior',
];

class OpRouteFiltersFiltering extends StatelessWidget {
  const OpRouteFiltersFiltering({super.key});

  @override
  Widget build(BuildContext context) {
    final currentFilters =
        context.select<SettingsProvider, Map<String, FilterDetail>>((prov) => prov.operatorFilters);

    final cacheProv = context.read<CacheProvider>();

    final List<FilterChip> rarityFilters = List.generate(6, (index) {
      final String rarityString = "${FilterType.rarity.prefix}_${(index + 1).toString()}";
      final String rarity = 'r${(index + 1).toString()}';

      return FilterChip(
        label: Text('${(index + 1).toString()} \u2605'),
        selected: currentFilters.containsKey(rarityString),
        avatar: currentFilters.containsKey(rarityString)
            ? Icon(
                currentFilters[rarityString]!.mode == FilterMode.whitelist
                    ? Icons.check
                    : Icons.block,
              )
            : null,
        onSelected: (_) => context.read<SettingsProvider>().toggleOperatorFilter(
              FilterTag(
                id: rarityString,
                key: rarity,
                type: FilterType.rarity,
              ),
            ),
        showCheckmark: false,
      );
    });

    final List<FilterChip> professionFilters = List.generate(professionList.length, (index) {
      final id = '${FilterType.profession.prefix}_${professionList[index]}';
      return FilterChip(
        label: Text(Operator.professionTranslate(professionList[index].toLowerCase())),
        selected: currentFilters.containsKey(id),
        avatar: currentFilters.containsKey(id)
            ? Icon(
                currentFilters[id]!.mode == FilterMode.whitelist ? Icons.check : Icons.block,
              )
            : null,
        onSelected: (_) => context.read<SettingsProvider>().toggleOperatorFilter(
              FilterTag(
                id: id,
                key: professionList[index],
                type: FilterType.profession,
              ),
            ),
        showCheckmark: false,
      );
    });

    List<Widget> subProfessionFilters() {
      List<Widget> result = [];

      for (var subclass in (cacheProv.cachedModTable!["subProfDict"] as Map).entries) {
        if ((subclass.key as String).startsWith('notchar') ||
            (subclass.key as String).startsWith('none')) continue;

        final id = '${FilterType.subprofession.prefix}_${subclass.key}';

        result.add(
          FilterChip(
            label: Text(subclass.value["subProfessionName"]),
            selected: currentFilters.containsKey(id),
            avatar: currentFilters.containsKey(id)
                ? Icon(
                    currentFilters[id]!.mode == FilterMode.whitelist ? Icons.check : Icons.block,
                  )
                : null,
            onSelected: (_) => context.read<SettingsProvider>().toggleOperatorFilter(
                  FilterTag(
                    id: id,
                    key: subclass.key,
                    type: FilterType.subprofession,
                  ),
                ),
            showCheckmark: false,
          ),
        );
      }

      return result;
    }

    List<Widget> factionFilters() {
      List<Widget> result = [];

      for (var faction in (cacheProv.cachedTeamTable as Map).entries) {
        if ((faction.key as String).startsWith('none')) continue;

        final id = '${FilterType.faction.prefix}_${faction.key}';

        result.add(
          FilterChip(
            label: Text(faction.value["powerName"]),
            selected: currentFilters.containsKey(id),
            avatar: currentFilters.containsKey(id)
                ? Icon(
                    currentFilters[id]!.mode == FilterMode.whitelist ? Icons.check : Icons.block,
                  )
                : null,
            onSelected: (_) => context.read<SettingsProvider>().toggleOperatorFilter(
                  FilterTag(
                    id: id,
                    key: (faction.value["powerId"] as String).toLowerCase(),
                    type: FilterType.faction,
                  ),
                ),
            showCheckmark: false,
          ),
        );
      }
      return result;
    }

    final List<FilterChip> extraFilters = [
      FilterChip(
        label: const Text('Has module'),
        selected: currentFilters.containsKey('has_module'),
        avatar: currentFilters.containsKey('has_module')
            ? Icon(
                currentFilters['has_module']!.mode == FilterMode.whitelist
                    ? Icons.check
                    : Icons.block,
              )
            : null,
        onSelected: (_) => context.read<SettingsProvider>().toggleOperatorFilter(
              FilterTag(
                id: 'has_module',
                key: '${FilterType.extra.prefix}_has_module',
                type: FilterType.extra,
              ),
            ),
        showCheckmark: false,
      ),
    ];

    List<Widget> taglistFilters() {
      List<Widget> result = [];

      for (var tag in (cacheProv.cachedGachaTable!["gachaTags"] as List)) {
        final int tagId = (tag as Map)["tagId"];
        if ((tagId >= 1 && tagId <= 11) || [14, 1012, 1013].contains(tagId)) {
          continue;
        }

        final id = '${FilterType.tag.prefix}_${(tag["tagName"] as String).toLowerCase()}';

        result.add(
          FilterChip(
            label: Text(tag["tagName"]),
            selected: currentFilters.containsKey(id),
            avatar: currentFilters.containsKey(id)
                ? Icon(
                    currentFilters[id]!.mode == FilterMode.whitelist ? Icons.check : Icons.block,
                  )
                : null,
            onSelected: (_) => context.read<SettingsProvider>().toggleOperatorFilter(
                  FilterTag(
                    id: id,
                    key: (tag["tagName"] as String).toLowerCase(),
                    type: FilterType.tag,
                  ),
                ),
            showCheckmark: false,
          ),
        );
      }
      return result;
    }

    List<Widget> positionFilters() {
      List<Widget> result = [];

      const List<String> positions = ["MELEE", "RANGED"];

      for (var pos in positions) {
        final id = '${FilterType.position.prefix}_${pos.toLowerCase()}';

        result.add(
          FilterChip(
            label: Text(pos.capitalize()),
            selected: currentFilters.containsKey(id),
            avatar: currentFilters.containsKey(id)
                ? Icon(
                    currentFilters[id]!.mode == FilterMode.whitelist ? Icons.check : Icons.block,
                  )
                : null,
            onSelected: (_) => context.read<SettingsProvider>().toggleOperatorFilter(
                  FilterTag(
                    id: id,
                    key: pos.toLowerCase(),
                    type: FilterType.position,
                  ),
                ),
            showCheckmark: false,
          ),
        );
      }
      return result;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 10),
        Center(
          child: OutlinedButton(
            onPressed: currentFilters.isNotEmpty
                ? context.read<SettingsProvider>().clearOperatorFilters
                : null,
            child: const Text('Clear filters'),
          ),
        ),
        FilterTile(
          title: 'Rarity',
          child: Wrap(
            spacing: 6.0,
            children: rarityFilters,
          ),
        ),
        FilterTile(
          title: 'Classes',
          child: Wrap(
            spacing: 6.0,
            children: professionFilters,
          ),
        ),
        FilterTile(
          title: 'Subclasses',
          child: Wrap(
            spacing: 6.0,
            children: subProfessionFilters(),
          ),
        ),
        FilterTile(
          title: 'Faction',
          child: Wrap(
            spacing: 6.0,
            children: factionFilters(),
          ),
        ),
        FilterTile(
          title: 'Tags',
          child: Wrap(
            spacing: 6.0,
            children: taglistFilters(),
          ),
        ),
        FilterTile(
          title: 'Position',
          child: Wrap(
            spacing: 6.0,
            children: positionFilters(),
          ),
        ),
        FilterTile(
          title: 'Extras',
          child: Wrap(
            spacing: 6.0,
            children: extraFilters,
          ),
        ),
      ],
    );
  }
}
