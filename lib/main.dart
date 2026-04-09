import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_developer_assignment_task/repo/product_repo.dart';
import 'package:get_it/get_it.dart' show GetIt;
import 'package:hive_ce_flutter/hive_flutter.dart';

import 'bloc/internet_connection_cubit/internet_connection_cubit.dart';

import 'bloc/location_bloc/location_bloc.dart';
import 'hive/hive_registrar.g.dart';
import 'model/task.dart' show Task;
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
    instanceName: 'tasksBox',
    () async => Hive.openBox<Task>('tasksBox'),
    dispose: (box) {
      box.close();
    },
  );
  GetIt.I.registerLazySingletonAsync<Box<Task>>(
    instanceName: 'unSyncedTasksBox',
    () async => Hive.openBox<Task>('unSyncedTasksBox'),
    dispose: (box) {
      box.close();
    },
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => InternetConnectionCubit()),
        BlocProvider(
          create: (context) => LocationBloc()..add(FetchLocationRequested()),
        ),
      ],
      child: MultiRepositoryProvider(
        providers: [
          RepositoryProvider(create: (context) => ProductRepository()),
          RepositoryProvider(create: (context) => TaskRepository()),
        ],
        child: MaterialApp.router(
          title: 'KUTOOT',
          routerConfig: AppRouter.router,
          debugShowCheckedModeBanner: false,
          theme: ThemeData(colorScheme: .fromSeed(seedColor: Colors.indigo)),
        ),
      ),
    );
  }
}
