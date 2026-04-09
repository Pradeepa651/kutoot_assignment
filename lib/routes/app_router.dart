import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_developer_assignment_task/bloc/product_bloc/product_bloc.dart';
import 'package:flutter_developer_assignment_task/page/dash_details_page.dart';
import 'package:flutter_developer_assignment_task/page/dash_page.dart'
    show DashPage;
import 'package:flutter_developer_assignment_task/routes/app_routes.dart'
    show AppRoutes;
import 'package:go_router/go_router.dart';
import '../page/home_page.dart' show HomePage;
import '../page/product_page.dart' show ProductPage;
import '../page/scanner_page.dart' show QRScannerScreen;
import '../page/task_page.dart' show TaskPage;

class AppRouter {
  static final GoRouter router = GoRouter(
    routes: [
      GoRoute(
        path: AppRoutes.initial,
        builder: (context, state) => const HomePage(),
        routes: [
          GoRoute(
            path: AppRoutes.products,
            builder: (context, state) => const ProductPage(),
          ),
          GoRoute(
            path: AppRoutes.tasks,
            builder: (context, state) => const TaskPage(),
          ),
          GoRoute(
            path: AppRoutes.dashboard,
            builder: (context, state) => const DashPage(),
          ),
          GoRoute(
            path: AppRoutes.qRScanner,
            builder: (context, state) => const QRScannerScreen(),
          ),
          GoRoute(
            path: AppRoutes.dashboardDetails,
            builder: (context, state) => BlocProvider.value(
              value: state.extra as ProductBloc,
              child: const DashDetailsPage(),
            ),
          ),
        ],
      ),
    ],
  );
}
