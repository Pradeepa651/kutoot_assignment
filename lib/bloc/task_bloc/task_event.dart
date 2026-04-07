part of 'task_bloc.dart';

sealed class TaskEvent extends Equatable {
  const TaskEvent();

  @override
  List<Object> get props => [];
}

final class TaskLoaded extends TaskEvent {
  const TaskLoaded();
}

final class TaskAdd extends TaskEvent {
  const TaskAdd();
}

final class TaskEdit extends TaskEvent {
  const TaskEdit();
}
