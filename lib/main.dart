import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_developer_assignment_task/repo/product_repo.dart';
import 'package:get_it/get_it.dart' show GetIt;
import 'package:hive_flutter/hive_flutter.dart';

import 'routes/app_router.dart' show AppRouter;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(const MyApp());
}

Future<void> initHive() async {
  await Hive.initFlutter();
  GetIt.I.registerLazySingletonAsync<Box>(() async => Hive.box('tasks'));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return RepositoryProvider(
      create: (context) => ProductRepository(),
      child: MaterialApp.router(
        title: 'Flutter Developer Assignment Task',
        routerConfig: AppRouter.router,
        theme: ThemeData(colorScheme: .fromSeed(seedColor: Colors.deepPurple)),
      ),
    );
  }
}
