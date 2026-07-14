// ignore_for_file: public_member_api_docs, sort_constructors_first

/// Represents a pre-computed tag combination and its result.
/// Used by the "show all combos" feature.
class RecruitAllCombo {
  final List<int> tagIds;
  final int rarity;
  final List<String> operatorNames;

  const RecruitAllCombo({
    required this.tagIds,
    required this.rarity,
    required this.operatorNames,
  });
}
