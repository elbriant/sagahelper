// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:sagahelper/models/operator.dart';

class RecruitOperator {
  final Operator op;
  final bool unique;
  final List<int> rarityTags;
  final List<int> positionTags;
  final List<int> classTags;
  final List<int> otherTags;

  RecruitOperator({
    required this.op,
    this.unique = false,
    required this.rarityTags,
    required this.positionTags,
    required this.classTags,
    required this.otherTags,
  });
}
