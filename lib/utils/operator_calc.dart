import 'package:flutter/material.dart' show AxisDirection;

class OperatorCalc {
  static AxisDirection? valueDifference(num current, num last) {
    if (current < last) {
      return AxisDirection.down;
    } else if (current == last) {
      return null;
    } else {
      return AxisDirection.up;
    }
  }
}
