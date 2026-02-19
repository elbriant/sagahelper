import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sagahelper/models/context_data.dart';

final contextProvider = NotifierProvider<ContextNotifier, ContextData>(ContextNotifier.new);

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
