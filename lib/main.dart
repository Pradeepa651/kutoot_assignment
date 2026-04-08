import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_developer_assignment_task/repo/product_repo.dart';
import 'package:get_it/get_it.dart' show GetIt;
import 'package:hive_ce_flutter/hive_flutter.dart';

import 'bloc/internet_connection_cubit/internet_connection_cubit.dart';

import 'hive/hive_registrar.g.dart';
import 'model/task.dart' show Task, TaskList;
import 'repo/task_repo.dart' show TaskRepository;
import 'routes/app_router.dart' show AppRouter;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initHive();
  runApp(const MyApp());
}

Future<void> initHive() async {
  await Hive.initFlutter();
  Hive.registerAdapters();
  GetIt.I.registerLazySingletonAsync<Box<Task>>(
    () async => Hive.openBox<Task>('tasksBox'),
    dispose: (box) {
      box.close();
    },
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => InternetConnectionCubit(),
      child: MultiRepositoryProvider(
        providers: [
          RepositoryProvider(create: (context) => ProductRepository()),
          RepositoryProvider(create: (context) => TaskRepository()),
        ],
        child: MaterialApp.router(
          title: 'Flutter Developer Assignment Task',
          routerConfig: AppRouter.router,
          theme: ThemeData(
            colorScheme: .fromSeed(seedColor: Colors.deepPurple),
          ),
        ),
      ),
    );
  }
}
