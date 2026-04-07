import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:hive_flutter/adapters.dart' show Box;

import '../../model/task.dart' show Task;

part 'task_event.dart';
part 'task_state.dart';

class TaskBloc extends Bloc<TaskEvent, TaskState> {
  TaskBloc() : super(TaskState(tasks: [], unSyncedTasks: [])) {
    on<TaskLoaded>(_onTaskLoaded);
    on<TaskAdded>(_onTaskAdded);

    on<TaskEdited>(_onTaskEdited);
    on<TaskSyncRequested>(_onTaskSyncRequested);
  }

  void _onTaskLoaded(TaskLoaded event, Emitter<TaskState> emit) async {
    try {
      // Simulate loading tasks from a local database or API
      final taskLocalDB = await GetIt.I.getAsync<Box>();
      final loadedTasks = taskLocalDB
          .get('tasks', defaultValue: [])
          .map((e) => Task.fromMap(Map<String, dynamic>.from(e)))
          .toList();
      _updateState(emit, tasks: loadedTasks);
    } catch (e) {
      _updateState(emit, tasks: [], unSyncedTasks: []);
    }
  }

  void _onTaskAdded(TaskAdded event, Emitter<TaskState> emit) async {
    final newTask = Task(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: event.title,
      description: event.description,
    );
    final updatedTasks = List<Task>.from(state.tasks)..add(newTask);
    try {
      final taskLocalDB = await GetIt.I.getAsync<Box>();
      taskLocalDB.put('tasks', [...state.tasks, newTask.toMap()]);

      _updateState(emit, tasks: updatedTasks);
    } on Exception catch (_) {
      final updatedUnSyncedTasks = List<Task>.from(state.unSyncedTasks)
        ..add(newTask);
      _updateState(emit, unSyncedTasks: updatedUnSyncedTasks);
    }
  }

  void _onTaskEdited(TaskEdited event, Emitter<TaskState> emit) {
    final updatedTasks = state.tasks.map((task) {
      if (task.id == event.id) {
        return Task(
          id: task.id,
          title: event.title,
          description: event.description,
        );
      }
      return task;
    }).toList();
    _updateState(emit, tasks: updatedTasks);
  }

  void _onTaskSyncRequested(TaskSyncRequested event, Emitter<TaskState> emit) {
    _updateState(emit, unSyncedTasks: []);
  }

  void _updateState(
    Emitter<TaskState> emit, {
    List<Task>? tasks,
    List<Task>? unSyncedTasks,
  }) async {
    emit(state.copyWith(tasks: tasks, unSyncedTasks: unSyncedTasks));
  }
}
