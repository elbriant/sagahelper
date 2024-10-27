import 'package:sagahelper/models/operator.dart';
import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';

class CacheProvider extends ChangeNotifier {
  List<Operator>? cachedListOperator;
  String? cachedListOperatorServer;
  String? cachedListOperatorVersion;
}