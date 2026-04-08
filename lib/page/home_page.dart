import 'package:flutter/material.dart';
import 'package:flutter_developer_assignment_task/routes/app_routes.dart';
import 'package:go_router/go_router.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Home')),
      body: Column(
        children: [
          Card(
            child: ListTile(
              title: const Text('Task 1'),
              subtitle: const Text('Performance Architect'),
              leading: const Icon(Icons.shopping_bag),
              onTap: () {
                context.push(AppRoutes.products);
              },
            ),
          ),
          Card(
            child: ListTile(
              title: const Text('Task 2'),
              subtitle: const Text('State Management & Sync'),
              leading: const Icon(Icons.list),
              onTap: () {
                context.push(AppRoutes.tasks);
              },
            ),
          ),
        ],
      ),
    );
  }
}
