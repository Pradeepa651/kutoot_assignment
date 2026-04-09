import 'dart:async' show StreamSubscription;

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/widgets.dart' show AppLifecycleListener;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';

import 'package:stream_transform/stream_transform.dart';

import '../../model/task.dart' show Task;
import '../../repo/task_repo.dart';

part 'task_event.dart';
part 'task_state.dart';

class TaskBloc extends Bloc<TaskEvent, TaskState> {
  late final StreamSubscription<List<ConnectivityResult>> _subscription;
  late final AppLifecycleListener _listener;
  final TaskRepository taskRepo;

  TaskBloc({required this.taskRepo})
    : super(TaskState(tasks: [], unSyncedTasks: [])) {
    on<TaskLoaded>(_onTaskLoaded);
    on<TaskAdded>(_onTaskAdded);

    on<TaskEdited>(_onTaskEdited);
    on<TaskSyncRequested>(_onTaskSyncRequested);
    on<_InternetStatusChanged>(_onInternetStatusChanged);

    _checkInternetConnection();
  }

  void _checkInternetConnection() {
    _subscription = Connectivity().onConnectivityChanged
        .debounce(const Duration(milliseconds: 1500))
        .listen(
          (List<ConnectivityResult> result) {
            if (result.contains(ConnectivityResult.wifi) ||
                result.contains(ConnectivityResult.mobile) ||
                result.contains(ConnectivityResult.ethernet)) {
              add(const _InternetStatusChanged(InternetStatus.online));
              add(const TaskSyncRequested());
            } else {
              add(const _InternetStatusChanged(InternetStatus.offline));
            }
          },
          onError: (error) {
            add(_InternetStatusChanged(InternetStatus.offline));
          },
        );
    _listener = AppLifecycleListener(
      onResume: _subscription.resume,
      onHide: _subscription.pause,
      onPause: _subscription.pause,
    );
  }

  @override
  Future<void> close() {
    _subscription.cancel();
    _listener.dispose();
    return super.close();
  }

  void _onInternetStatusChanged(
    _InternetStatusChanged event,
    Emitter<TaskState> emit,
  ) {
    emit(state.copyWith(internetStatus: event.status));
  }

  void _onTaskLoaded(TaskLoaded event, Emitter<TaskState> emit) async {
    try {
      final taskLocalDB = await GetIt.I.getAsync<Box<Task>>(
        instanceName: 'tasksBox',
      );
      final unSyncedTaskLocalDB = await GetIt.I.getAsync<Box<Task>>(
        instanceName: 'unSyncedTasksBox',
      );
      if (state.internetStatus == InternetStatus.online) {
        final fetchedTasks = await taskRepo.fetchTasks();
        await taskLocalDB.clear();
        await taskLocalDB.addAll(fetchedTasks);
        _updateState(
          emit,
          tasks: List.from(fetchedTasks),

          status: Status.success,
        );
      } else {
        final loadedTasks = taskLocalDB.values;
        _updateState(
          emit,
          tasks: List.from(loadedTasks),
          unSyncedTasks: List.from(unSyncedTaskLocalDB.values),
          status: Status.success,
        );
      }
    } catch (e) {
      _updateState(emit, status: Status.error, errorMessage: e.toString());
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
      if (state.internetStatus == InternetStatus.offline) {
        final updatedUnSyncedTasks = List<Task>.from(state.unSyncedTasks)
          ..add(newTask);
        _updateState(
          emit,
          unSyncedTasks: updatedUnSyncedTasks,
          tasks: updatedTasks,
          syncStatus: SyncStatus.error,
          showSyncError: true,
        );
        final unSyncedTaskLocalDB = await GetIt.I.getAsync<Box<Task>>(
          instanceName: 'unSyncedTasksBox',
        );
        await unSyncedTaskLocalDB.add(newTask);
      } else {
        await taskRepo.addTasks(newTask);
        _updateState(emit, tasks: updatedTasks, syncStatus: SyncStatus.success);
      }
    } finally {
      final taskLocalDB = await GetIt.I.getAsync<Box<Task>>(
        instanceName: 'tasksBox',
      );

      await taskLocalDB.add(newTask);
    }
  }

  void _onTaskEdited(TaskEdited event, Emitter<TaskState> emit) async {
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
    _updateState(emit, tasks: updatedTasks, status: Status.updated);
    try {
      if (state.internetStatus == InternetStatus.offline) {
        final updatedUnSyncedTasks = List<Task>.from(state.unSyncedTasks)
          ..add(updatedTasks.firstWhere((task) => task.id == event.id));
        _updateState(
          emit,
          unSyncedTasks: updatedUnSyncedTasks,
          syncStatus: SyncStatus.error,
          showSyncError: true,
        );
        final unSyncedTaskLocalDB = await GetIt.I.getAsync<Box<Task>>(
          instanceName: 'unSyncedTasksBox',
        );
        await unSyncedTaskLocalDB.add(
          updatedTasks.firstWhere((task) => task.id == event.id),
        );
      } else {
        await taskRepo.updateTasks(
          updatedTasks.firstWhere((task) => task.id == event.id),
        );
        _updateState(emit, syncStatus: SyncStatus.success);
      }
    } finally {
      await GetIt.I.getAsync<Box<Task>>(instanceName: 'tasksBox').then((
        taskLocalDB,
      ) async {
        final index = taskLocalDB.values.toList().indexWhere(
          (task) => task.id == event.id,
        );
        if (index != -1) {
          await taskLocalDB.putAt(
            index,
            updatedTasks.firstWhere((task) => task.id == event.id),
          );
        }
      });
    }
  }

  void _onTaskSyncRequested(
    TaskSyncRequested event,
    Emitter<TaskState> emit,
  ) async {
    try {
      await taskRepo.syncTasks(state.unSyncedTasks);
      _updateState(emit, syncStatus: SyncStatus.success, unSyncedTasks: []);
      await GetIt.I.getAsync<Box<Task>>(instanceName: 'unSyncedTasksBox').then((
        unSyncedTaskLocalDB,
      ) async {
        await unSyncedTaskLocalDB.clear();
      });
    } catch (e) {
      _updateState(
        emit,
        syncStatus: SyncStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  void _updateState(
    Emitter<TaskState> emit, {
    List<Task>? tasks,
    List<Task>? unSyncedTasks,
    Status? status,
    SyncStatus? syncStatus,
    InternetStatus? internetStatus,
    String? errorMessage,
    bool? showSyncError,
  }) async {
    emit(
      state.copyWith(
        tasks: tasks,
        unSyncedTasks: unSyncedTasks,
        status: status,
        syncStatus: syncStatus,
        internetStatus: internetStatus,
        errorMessage: errorMessage,
        showSyncError: showSyncError,
      ),
    );
  }
}
