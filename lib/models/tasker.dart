import 'package:flutter/material.dart';
import 'package:sagahelper/models/task.dart';

@immutable
class Tasker {
  final List<Task> taskQueue;

  bool get isActive => taskQueue.isNotEmpty;

  const Tasker({
    this.taskQueue = const [],
  });

  Tasker copyWith({
    bool? isDownloading,
    bool? isUpdating,
    List<Task>? taskQueue,
  }) {
    return Tasker(
      taskQueue: taskQueue ?? this.taskQueue,
    );
  }
}
