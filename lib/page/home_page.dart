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
          RepaintBoundary(
            child: Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Colors.white, Colors.white70, Colors.black12],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),

                borderRadius: BorderRadius.circular(8),
              ),

              child: ListTile(
                title: const Text('Products'),
                subtitle: const Text('View our product catalog'),
                leading: const Icon(Icons.shopping_bag),
                onTap: () {
                  context.push(AppRoutes.products);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
