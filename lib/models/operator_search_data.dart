import 'package:flutter/material.dart';
import 'package:sagahelper/models/filters.dart';

@immutable
class OperatorSearchData {
  final bool isSearching;
  final String searchFilterString;
  final Map<String, FilterDetail> operatorFilters;

  const OperatorSearchData({
    this.isSearching = false,
    this.searchFilterString = '',
    this.operatorFilters = const {},
  });

  OperatorSearchData copyWith({
    bool? isSearching,
    String? searchFilterString,
    Map<String, FilterDetail>? operatorFilters,
  }) {
    return OperatorSearchData(
      isSearching: isSearching ?? this.isSearching,
      searchFilterString: searchFilterString ?? this.searchFilterString,
      operatorFilters: operatorFilters ?? this.operatorFilters,
    );
  }
}
