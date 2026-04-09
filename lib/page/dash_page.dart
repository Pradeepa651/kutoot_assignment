import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_developer_assignment_task/bloc/internet_connection_cubit/internet_connection_cubit.dart';
import 'package:flutter_developer_assignment_task/bloc/location_bloc/location_bloc.dart';
import 'package:flutter_developer_assignment_task/bloc/product_bloc/product_bloc.dart';
import 'package:flutter_developer_assignment_task/model/products.dart';
import 'package:flutter_developer_assignment_task/repo/product_repo.dart';
import 'package:flutter_developer_assignment_task/routes/app_routes.dart';
import 'package:flutter_developer_assignment_task/utils/const.dart';
import 'package:go_router/go_router.dart';
import 'package:permission_handler/permission_handler.dart';

import '../utils/comonents/location_view.dart';
import '../utils/comonents/nav_bar.dart' show FloatingNavBar;
import '../utils/comonents/search.dart' show SearchComponents;

class DashPage extends StatefulWidget {
  const DashPage({super.key});

  @override
  State<DashPage> createState() => _DashPageState();
}

class _DashPageState extends State<DashPage> {
  late final ValueNotifier<int> _page;

  @override
  void initState() {
    super.initState();
    _page = ValueNotifier(0);
  }

  @override
  void dispose() {
    _page.dispose();
    super.dispose();
  }

  final List<Widget> _pages = [
    const Center(child: Text('Home Page', style: TextStyle(fontSize: 24))),
    const Center(child: Text('Search Page', style: TextStyle(fontSize: 24))),
    const Center(child: Text('Profile Page', style: TextStyle(fontSize: 24))),
  ];
  Future<void> _checkAndRequestPermission(BuildContext context) async {
    // 1. Check the current status
    PermissionStatus status = await Permission.camera.status;

    // 2. If not granted, request it
    if (!status.isGranted) {
      status = await Permission.camera.request();
    }

    // 3. Handle the result
    if (status.isGranted) {
      // Permission granted! Navigate to the scanner
      if (context.mounted) {
        context.push(AppRoutes.qRScanner);
      }
    } else if (status.isDenied) {
      // User denied the permission this time
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Camera permission is required to scan QR codes.'),
          ),
        );
      }
    } else if (status.isPermanentlyDenied) {
      // User permanently denied it (checked "Don't ask again")
      // We must direct them to the app settings
      if (context.mounted) {
        _showSettingsDialog(context);
      }
    }
  }

  void _showSettingsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Camera Permission Required'),
        content: const Text(
          'You have permanently denied camera access. Please enable it in the app settings to use the scanner.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              openAppSettings(); // Opens the device's settings app
            },
            child: const Text('Open Settings'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          ProductBloc(productRepository: context.read<ProductRepository>())
            ..add(ProductFetched()),
      child: BlocListener<InternetConnectionCubit, InternetConnectionState>(
        listener: (context, state) {
          if (state is InternetConnectionConnected) {
            context.read<ProductBloc>().add(ProductFetched());
            context.read<LocationBloc>().add(FetchLocationRequested());
          }
        },
        child: Scaffold(
          floatingActionButton: FloatingActionButton(
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
            onPressed: () => _checkAndRequestPermission(context),
            child: Icon(Icons.qr_code_scanner_sharp),
          ),
          bottomNavigationBar: ValueListenableBuilder(
            valueListenable: _page,
            builder: (context, value, child) {
              return FloatingNavBar(
                selectedIndex: value,
                onItemTapped: (index) {
                  _page.value = index;
                },
              );
            },
          ),
          body: SafeArea(
            child: CustomScrollView(
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.all(16.0),
                  sliver: SliverToBoxAdapter(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        LocationView(),
                        Image.asset('assets/image/download.png', width: 100),
                        FilledButtonTheme(
                          data: FilledButtonThemeData(
                            style: FilledButton.styleFrom(
                              backgroundColor: Colors.red.shade800,
                              foregroundColor: Colors.white,
                            ),
                          ),
                          child: FilledButton(
                            onPressed: () {},
                            child: Text('Upgrade'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                DecoratedSliver(
                  decoration: BoxDecoration(color: Colors.grey.shade200),
                  sliver: SliverMainAxisGroup(
                    slivers: [
                      SliverPadding(
                        padding: const EdgeInsets.all(24),
                        sliver: SliverToBoxAdapter(child: SearchComponents()),
                      ),
                      SliverPadding(
                        padding: const EdgeInsets.all(24).copyWith(top: 12),
                        sliver: SliverToBoxAdapter(
                          child: Container(
                            height: 200,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              image: DecorationImage(
                                image: AssetImage(
                                  'assets/image/hero_image.webp',
                                ),
                                fit: BoxFit.cover,
                              ),
                            ),
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.black.withValues(alpha: 0.6),
                                    Colors.transparent,
                                  ],
                                  begin: Alignment.bottomCenter,
                                  end: Alignment.topCenter,
                                ),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 16,
                              ),
                              alignment: Alignment.bottomLeft,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: .start,

                                spacing: 8,
                                children: [
                                  HighLiteCard(text: 'Free Trails'),
                                  Text(
                                    'Welcome Back!',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                DiscoverCategories(),
                NearBy(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class HighLiteCard extends StatelessWidget {
  const HighLiteCard({super.key, required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.yellow,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      child: Text(text, style: TextTheme.of(context).labelLarge),
    );
  }
}

class DiscoverCategories extends StatelessWidget {
  const DiscoverCategories({super.key});

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.all(16),
      sliver: SliverToBoxAdapter(
        child: Column(
          crossAxisAlignment: .start,
          spacing: 8,
          children: [
            Text(
              'DISCOVER CATEGORIES',
              style: TextTheme.of(
                context,
              ).titleSmall?.copyWith(color: Colors.grey.shade600),
            ),
            SizedBox(
              height: 100,
              child: ListView.builder(
                itemBuilder: (context, index) {
                  final item = menuList[index];
                  return Column(
                    children: [
                      Container(
                        margin: const EdgeInsets.symmetric(
                          vertical: 6,
                          horizontal: 12,
                        ),
                        height: 50,
                        width: 50,

                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),

                          gradient: LinearGradient(
                            colors: [
                              item.color.withValues(alpha: .85),
                              item.color.withValues(alpha: .9),
                              item.color,
                            ],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.05),
                              blurRadius: 8,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Icon(item.icon, color: Colors.white),
                      ),
                      Text(
                        item.title,
                        style: TextTheme.of(context).labelLarge?.copyWith(
                          color: Colors.grey.shade800,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  );
                },
                scrollDirection: Axis.horizontal,
                itemCount: menuList.length,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class NearBy extends StatelessWidget {
  const NearBy({super.key});

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.all(16).copyWith(top: 0),
      sliver: SliverToBoxAdapter(
        child: Column(
          crossAxisAlignment: .start,
          spacing: 8,
          children: [
            Row(
              children: [
                Text('STORES NEARBY', style: TextTheme.of(context).titleSmall),
                Spacer(),
                TextButton(
                  onPressed: () {
                    context.push(
                      AppRoutes.dashboardDetails,
                      extra: context.read<ProductBloc>(),
                    );
                  },
                  style: TextButton.styleFrom(
                    alignment: Alignment.center,

                    foregroundColor: Colors.red.shade800,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,

                    children: [
                      Text('See All'),
                      Icon(Icons.arrow_right_rounded, size: 36),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 200,
              child: BlocBuilder<ProductBloc, ProductState>(
                builder: (context, state) {
                  if (state.apiStatus == ApiStatus.loading) {
                    return Center(
                      child: RepaintBoundary(
                        child: CircularProgressIndicator(),
                      ),
                    );
                  }
                  if (state.apiStatus == ApiStatus.error) {
                    return Center(
                      child: Text(
                        state.errorMessage ?? 'Something Went wrong!',
                      ),
                    );
                  }
                  return ListView.builder(
                    itemBuilder: (context, index) {
                      final product = state.products[index];
                      return ProductCard(product: product);
                    },
                    scrollDirection: Axis.horizontal,
                    itemCount: state.products.length,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ProductCard extends StatelessWidget {
  const ProductCard({super.key, required this.product});

  final Product product;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(8),

      width: 140,

      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        image: DecorationImage(image: NetworkImage(product.thumbnail)),

        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(
                colors: [Colors.black26, Colors.black54],
              ),
            ),
          ),
          Positioned(top: 8, left: 8, child: HighLiteCard(text: 'Best offers')),
          Positioned(
            bottom: 8,
            left: 8,
            width: 100,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.title,
                  maxLines: 1,
                  style: TextTheme.of(context).labelLarge?.copyWith(
                    color: Colors.white,
                    overflow: TextOverflow.clip,
                  ),
                ),
                Row(
                  children: [
                    Icon(Icons.star, color: Colors.amber, size: 16),
                    Text(
                      '${product.rating} ',

                      style: TextTheme.of(context).labelMedium?.copyWith(
                        color: Colors.white,

                        overflow: TextOverflow.clip,
                      ),
                    ),
                  ],
                ),
                Text(
                  " ${product.availabilityStatus}",

                  style: TextTheme.of(context).labelMedium?.copyWith(
                    color: Colors.white,

                    overflow: TextOverflow.clip,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
