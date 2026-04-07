part of 'task_bloc.dart';

class TaskState extends Equatable {
  const TaskState({required this.tasks, required this.unSyncedTasks});
  final List<Task> tasks;
  final List<Task> unSyncedTasks;

  @override
  List<Object> get props => [tasks, unSyncedTasks];

  TaskState copyWith({List<Task>? tasks, List<Task>? unSyncedTasks}) {
    return TaskState(
      tasks: tasks ?? this.tasks,
      unSyncedTasks: unSyncedTasks ?? this.unSyncedTasks,
    );
  }
}
