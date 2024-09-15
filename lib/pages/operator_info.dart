import 'package:docsprts/pages/operators_page.dart';
import 'package:flutter/material.dart';

class OperatorInfo extends StatelessWidget {
  final Operator operator;
  const OperatorInfo(this.operator, {super.key});

  @override
  Widget build(BuildContext context) {


    return Scaffold(
      appBar: AppBar(leading: IconButton(onPressed: () => Navigator.of(context).pop, icon: const Icon(Icons.arrow_back)), title: Text(operator.name)),
      body: const Placeholder(),
    );
  }
}