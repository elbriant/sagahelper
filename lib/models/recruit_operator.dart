// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:sagahelper/models/operator.dart';

class RecruitOperator {
  final Operator op;
  final bool unique;
  final List<int> allTagIds;
  final List<String> allTagNames;
  final List<String> tagNamesNoRarity;

  const RecruitOperator({
    required this.op,
    this.unique = false,
    required this.allTagIds,
    required this.allTagNames,
    required this.tagNamesNoRarity,
  });
}
