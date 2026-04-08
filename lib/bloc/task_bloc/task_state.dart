part of 'task_bloc.dart';

enum Status { initial, loading, success, error, refresh, unAuthorized, updated }

enum SyncStatus { initial, syncing, success, error }

enum InternetStatus { initial, online, offline }

class TaskState extends Equatable {
  const TaskState({
    required this.tasks,
    required this.unSyncedTasks,
    this.status = Status.initial,
    this.syncStatus = SyncStatus.initial,
    this.internetStatus = InternetStatus.initial,
    this.errorMessage,
    this.showSyncError = false,
  });
  final List<Task> tasks;
  final bool showSyncError;
  final List<Task> unSyncedTasks;
  final Status status;
  final SyncStatus syncStatus;

  final InternetStatus internetStatus;
  final String? errorMessage;

  TaskState copyWith({
    List<Task>? tasks,
    List<Task>? unSyncedTasks,
    Status? status,
    SyncStatus? syncStatus,
    InternetStatus? internetStatus,
    String? errorMessage,
    bool? showSyncError,
  }) {
    return TaskState(
      tasks: tasks ?? this.tasks,
      unSyncedTasks: unSyncedTasks ?? this.unSyncedTasks,
      syncStatus: syncStatus ?? this.syncStatus,
      internetStatus: internetStatus ?? this.internetStatus,
      errorMessage: errorMessage ?? this.errorMessage,
      status: status ?? this.status,
      showSyncError: showSyncError ?? this.showSyncError,
    );
  }

  @override
  List<Object> get props => [
    tasks,
    unSyncedTasks,
    status,
    syncStatus,
    internetStatus,
    ?errorMessage,
    showSyncError,
  ];
}
