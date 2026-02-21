class FilterDetail {
  final String key;
  FilterMode mode;
  final FilterType type;

  FilterDetail({required this.key, required this.mode, required this.type});
}

/// used to add or modify existing tags in operator info filtering
class FilterTag {
  /// key to search in the rules map of the filtering/sorting
  /// recomended to be different than key
  /// you could do "[FilterType.prefix]_[key]"
  final String id;

  /// exact id of the atribute to sort
  final String key;

  /// filterType to be used in the sorting/filtering algorithm
  final FilterType type;

  FilterTag({
    required this.id,
    required this.key,
    required this.type,
  });
}

enum OperatorSortingType {
  alphabetical,
  rarity,
  creation,
}

enum FilterType {
  profession('class'),
  subprofession('subclass'),
  rarity('rarity'),
  faction('faction'),
  position('position'),
  tag('taglist'),
  extra('extra');

  const FilterType(this.prefix);
  final String prefix;
}

enum CustomFilterTags {
  hasModule('has_module');

  const CustomFilterTags(this.tag);
  final String tag;
}

enum FilterMode {
  whitelist,
  blacklist,
}
