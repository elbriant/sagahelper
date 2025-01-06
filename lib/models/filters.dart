class FilterDetail {
  final String key;
  FilterMode mode;
  final FilterType type;

  FilterDetail({required this.key, required this.mode, required this.type});
}

enum OrderType {
  alphabetical,
  rarity,
  creation;

  const OrderType();

  int toJson() => index;
  static OrderType? fromJson(int? index) => index != null ? OrderType.values[index] : null;
}

enum FilterType {
  profession,
  subprofession,
  rarity,
}

enum FilterMode {
  whitelist,
  blacklist,
}
