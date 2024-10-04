import 'package:docsprts/pages/operators_page.dart';
import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';

class CacheProvider extends ChangeNotifier {
  List<Operator>? cachedListOperator;
  String? cachedListOperatorServer;
}