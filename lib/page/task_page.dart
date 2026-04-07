import 'package:flutter/material.dart';

class TaskPage extends StatelessWidget {
  const TaskPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Task Page')),
      body: TaskListView(),
    );
  }
}

class TaskListView extends StatelessWidget {
  const TaskListView({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) => ListTile(
              title: Text('Task ${index + 1}'),
              subtitle: Text('Description for Task ${index + 1}'),
            ),
            childCount: 20,
          ),
        ),
      ],
    );
  }
}
