import 'package:flutter_developer_assignment_task/routes/app_routes.dart'
    show AppRoutes;
import 'package:go_router/go_router.dart';
import '../page/home_page.dart' show HomePage;
import '../page/product_page.dart' show ProductPage;

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
        ],
      ),
    ],
  );
}
