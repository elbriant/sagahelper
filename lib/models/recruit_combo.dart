// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:sagahelper/models/recruit_operator.dart';

class RecruitCombo {
  final List<int> tagIds;
  final List<RecruitOperator> matches;
  final int lowestRarity;
  final int highestRarity;
  final int matchCount;

  const RecruitCombo({
    required this.tagIds,
    required this.matches,
    required this.lowestRarity,
    required this.highestRarity,
    required this.matchCount,
  });
}
