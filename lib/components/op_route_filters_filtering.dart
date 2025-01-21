import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sagahelper/components/filter_tile.dart';
import 'package:sagahelper/models/filters.dart';
import 'package:sagahelper/models/operator.dart';
import 'package:sagahelper/providers/cache_provider.dart';
import 'package:sagahelper/providers/settings_provider.dart';

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
      final String rarityString = 'r${(index + 1).toString()}';

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
        onSelected: (_) => context
            .read<SettingsProvider>()
            .toggleOperatorFilter(rarityString, rarityString, FilterType.rarity),
        showCheckmark: false,
      );
    });

    final List<FilterChip> professionFilters = List.generate(professionList.length, (index) {
      final id = 'class_${professionList[index]}';
      return FilterChip(
        label: Text(Operator.professionTranslate(professionList[index].toLowerCase())),
        selected: currentFilters.containsKey(id),
        avatar: currentFilters.containsKey(id)
            ? Icon(
                currentFilters[id]!.mode == FilterMode.whitelist ? Icons.check : Icons.block,
              )
            : null,
        onSelected: (_) => context
            .read<SettingsProvider>()
            .toggleOperatorFilter(id, professionList[index], FilterType.profession),
        showCheckmark: false,
      );
    });

    List<Widget> subProfessionFilters() {
      List<Widget> result = [];

      for (var subclass in (cacheProv.cachedModTable!["subProfDict"] as Map).entries) {
        if ((subclass.key as String).startsWith('notchar') ||
            (subclass.key as String).startsWith('none')) continue;

        final id = 'subclass_${subclass.key}';

        result.add(
          FilterChip(
            label: Text(subclass.value["subProfessionName"]),
            selected: currentFilters.containsKey(id),
            avatar: currentFilters.containsKey(id)
                ? Icon(
                    currentFilters[id]!.mode == FilterMode.whitelist ? Icons.check : Icons.block,
                  )
                : null,
            onSelected: (_) => context
                .read<SettingsProvider>()
                .toggleOperatorFilter(id, subclass.key, FilterType.subprofession),
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

        final id = 'faction_${faction.key}';

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
                  id,
                  (faction.value["powerId"] as String).toLowerCase(),
                  FilterType.faction,
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
              'has_module',
              'has_module',
              FilterType.extra,
            ),
        showCheckmark: false,
      ),
    ];

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
