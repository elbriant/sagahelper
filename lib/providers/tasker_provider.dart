import 'package:flutter/foundation.dart' show immutable;
import 'package:flutter_riverpod/flutter_riverpod.dart';

final taskerProvider = NotifierProvider<TaskerNotifier, Tasker>(TaskerNotifier.new);

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

class TaskerNotifier extends Notifier<Tasker> {
  @override
  build() {
    return const Tasker();
  }

  /// Adds a new task and returns its ID
  String addTask(String message) {
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    final newTask = Task(id: id, message: message);

    state = state.copyWith(
      taskQueue: [...state.taskQueue, newTask],
    );

    return id;
  }

  /// Updates an existing task and returns its ID
  String updateTask(String id, String message) {
    final index = state.taskQueue.indexWhere((task) => task.id == id);
    if (index == -1) return id;

    final updatedTask = state.taskQueue[index].copyWith(message: message);
    final newQueue = List<Task>.from(state.taskQueue);
    newQueue[index] = updatedTask;

    state = state.copyWith(taskQueue: newQueue);
    return id;
  }

  /// Removes a task by ID
  void removeTask(String id) {
    state = state.copyWith(
      taskQueue: state.taskQueue.where((task) => task.id != id).toList(),
    );
  }

  /// clear
  void completeAllTasks() {
    state = const Tasker();
  }
}
