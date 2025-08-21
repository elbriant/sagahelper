import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final contextProvider = NotifierProvider<ContextNotifier, ContextData>(ContextNotifier.new);

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

class ContextNotifier extends Notifier<ContextData> {
  @override
  ContextData build() {
    return const ContextData(brightness: Brightness.light);
  }

  void update(ContextData data) {
    state = state.copyWith(
      brightness: data.brightness,
    );
  }
}
