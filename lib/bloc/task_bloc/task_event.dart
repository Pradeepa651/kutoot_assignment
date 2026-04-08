part of 'task_bloc.dart';

sealed class TaskEvent extends Equatable {
  const TaskEvent();

  @override
  List<Object> get props => [];
}

final class TaskLoaded extends TaskEvent {
  const TaskLoaded();
}

final class TaskAdded extends TaskEvent {
  final String title;
  final String description;
  const TaskAdded({required this.title, required this.description});

  @override
  List<Object> get props => [title, description];
}

final class TaskEdited extends TaskEvent {
  final String id;
  final String title;
  final String description;
  const TaskEdited({
    required this.id,
    required this.title,
    required this.description,
  });

  @override
  List<Object> get props => [id, title, description];
}

final class TaskSyncRequested extends TaskEvent {
  const TaskSyncRequested();
}

final class _InternetStatusChanged extends TaskEvent {
  final InternetStatus status;
  const _InternetStatusChanged(this.status);

  @override
  List<Object> get props => [status];
}
