import '../../model/task.dart' show Task;

class TaskRepository {
  Future<List<Task>> fetchTasks() async {
    await Future.delayed(const Duration(seconds: 2));
    return [];
  }

  Future<Task> updateTasks(Task task) async {
    await Future.delayed(const Duration(seconds: 2));
    return task;
  }

  Future<Task> addTasks(Task task) async {
    await Future.delayed(const Duration(seconds: 2));
    return task;
  }

  Future<void> syncTasks(List<Task> tasks) async {
    await Future.delayed(const Duration(seconds: 2));
  }
}
