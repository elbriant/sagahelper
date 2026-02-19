import 'package:flutter/material.dart';

@immutable
class Task {
  final String id;
  final String message;

  const Task({
    required this.id,
    required this.message,
  });

  Task copyWith({
    String? id,
    String? message,
  }) {
    return Task(
      id: id ?? this.id,
      message: message ?? this.message,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Task && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
