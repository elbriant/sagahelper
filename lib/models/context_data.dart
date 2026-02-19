import 'package:flutter/material.dart';

@immutable
class ContextData {
  final Brightness brightness;
  const ContextData({
    required this.brightness,
  });

  ContextData copyWith({
    Brightness? brightness,
  }) {
    return ContextData(
      brightness: brightness ?? this.brightness,
    );
  }
}
