import 'dart:convert';

class Task {
  final String id;

  final String title;

  final String description;

  Task({required this.id, required this.title, required this.description});

  Task copyWith({String? id, String? title, String? description}) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'title': title,
      'description': description,
    };
  }

  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id'] as String,
      title: map['title'] as String,
      description: map['description'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory Task.fromJson(String source) =>
      Task.fromMap(json.decode(source) as Map<String, dynamic>);
}

class TaskList {
  final List<Task> tasks;

  TaskList({required this.tasks});

  Map<String, dynamic> toMap() {
    return <String, dynamic>{'tasks': tasks.map((x) => x.toMap()).toList()};
  }

  factory TaskList.fromMap(Map<String, dynamic> map) {
    return TaskList(
      tasks: List<Task>.from(map['tasks']?.map((x) => Task.fromMap(x))),
    );
  }

  String toJson() => json.encode(toMap());

  factory TaskList.fromJson(String source) =>
      TaskList.fromMap(json.decode(source) as Map<String, dynamic>);
}
