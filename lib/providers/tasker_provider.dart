import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sagahelper/models/task.dart';
import 'package:sagahelper/models/tasker.dart';

final taskerProvider = NotifierProvider<TaskerNotifier, Tasker>(TaskerNotifier.new);

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
