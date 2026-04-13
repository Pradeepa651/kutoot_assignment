import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_developer_assignment_task/utils/widgets/rounded_container.dart';

import '../bloc/internet_connection_cubit/internet_connection_cubit.dart';
import '../bloc/location_bloc/location_bloc.dart';
import '../bloc/product_bloc/product_bloc.dart';
import '../model/products.dart' show Product;
import '../utils/comonents/location_view.dart';
import '../utils/comonents/search.dart' show SearchComponents;

class DashDetailsPage extends StatelessWidget {
  const DashDetailsPage({super.key});

  void _fetchNextProducts(BuildContext context) {
    if (context.read<ProductBloc>().state.apiStatus != ApiStatus.loading &&
        !context.read<ProductBloc>().state.hasMaxReached) {
      context.read<ProductBloc>().add(ProductFetched());
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<InternetConnectionCubit, InternetConnectionState>(
      listener: (context, state) {
        if (state is InternetConnectionConnected) {
          if (context.read<ProductBloc>().state.apiStatus == ApiStatus.error) {
            context.read<ProductBloc>().add(ProductFetched());
            context.read<LocationBloc>().add(FetchLocationRequested());
          }
        }
      },
      child: Scaffold(
        body: SafeArea(
          child: NotificationListener<ScrollUpdateNotification>(
            onNotification: (scrollInfo) {
              if (scrollInfo.metrics.pixels >=
                  scrollInfo.metrics.maxScrollExtent - 200) {
                _fetchNextProducts(context);
              }

              return false;
            },
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
                HeroComponents(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class HeroComponents extends StatefulWidget {
  const HeroComponents({super.key});

  @override
  State<HeroComponents> createState() => _HeroComponentsState();
}

class _HeroComponentsState extends State<HeroComponents>
    with SingleTickerProviderStateMixin {
  late TabController tabController;
  late ValueNotifier<int> tab;
  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 4, vsync: this);
    tab = ValueNotifier(0);
    tabController.addListener(updateTab);
  }

  void updateTab() {
    tab.value = tabController.index;
  }

  @override
  void dispose() {
    tabController.removeListener(updateTab);
    tab.dispose();
    tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DecoratedSliver(
      decoration: BoxDecoration(color: Colors.grey.shade200),
      sliver: SliverMainAxisGroup(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.all(24),
            sliver: SliverToBoxAdapter(child: SearchComponents()),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(24).copyWith(top: 12, left: 12),
            sliver: SliverToBoxAdapter(
              child: ValueListenableBuilder(
                valueListenable: tab,
                builder: (context, value, child) {
                  return TabBar(
                    controller: tabController,
                    dividerHeight: 0,
                    indicatorSize: .tab,
                    indicatorPadding: .symmetric(horizontal: 0, vertical: 4),
                    labelColor: Colors.white,
                    isScrollable: true,
                    tabAlignment: .center,

                    indicator: BoxDecoration(
                      color: Colors.deepOrangeAccent,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    tabs: [
                      value == 0
                          ? Tab(text: 'All', iconMargin: EdgeInsets.zero)
                          : CustomTab(text: 'All'),
                      value == 1
                          ? Tab(text: 'Fashion', iconMargin: EdgeInsets.zero)
                          : CustomTab(text: 'Fashion'),
                      value == 2
                          ? Tab(text: 'Electronic', iconMargin: EdgeInsets.zero)
                          : CustomTab(text: 'Electronic'),
                      value == 3
                          ? Tab(text: 'Foods', iconMargin: EdgeInsets.zero)
                          : CustomTab(text: 'Foods'),
                    ],
                  );
                },
              ),
            ),
          ),

          NearByStories(),
        ],
      ),
    );
  }
}

class CustomTab extends StatelessWidget {
  const CustomTab({super.key, required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Tab(
      iconMargin: EdgeInsets.zero,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: Colors.white,
        ),
        child: Text(text),
      ),
    );
  }
}

class NearByStories extends StatelessWidget {
  const NearByStories({super.key});

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.all(16).copyWith(top: 0),
      sliver: SliverMainAxisGroup(
        slivers: [
          SliverToBoxAdapter(
            child: Row(
              children: [
                Text(
                  'Nearby curated Stories',
                  style: TextTheme.of(context).titleMedium,
                ),
                Spacer(),
                TextButton(
                  onPressed: () {},
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
          ),
          BlocSelector<ProductBloc, ProductState, List<Product>>(
            selector: (state) => state.products,
            builder: (context, state) {
              return SliverLayoutBuilder(
                builder: (context, size) {
                  return SliverGrid.builder(
                    gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: 250,
                      mainAxisExtent: 265,
                    ),
                    itemBuilder: (context, index) {
                      final product = state[index];
                      return ProductGridCard(product: product);
                    },

                    itemCount: state.length,
                  );
                },
              );
            },
          ),

          BlocBuilder<ProductBloc, ProductState>(
            builder: (context, state) {
              if (state.apiStatus == ApiStatus.loading) {
                return SliverToBoxAdapter(
                  child: SizedBox(
                    height: 50,
                    child: Center(
                      child: RepaintBoundary(
                        child: CircularProgressIndicator(),
                      ),
                    ),
                  ),
                );
              }
              if (state.apiStatus == ApiStatus.error) {
                return SliverToBoxAdapter(
                  child: SizedBox(
                    height: 50,
                    child: Center(
                      child: Text(
                        state.errorMessage ?? 'Something Went wrong!',
                      ),
                    ),
                  ),
                );
              }
              return SliverToBoxAdapter();
            },
          ),
        ],
      ),
    );
  }
}

class ProductGridCard extends StatelessWidget {
  const ProductGridCard({super.key, required this.product});
  final Product product;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: [
          Container(
            height: 150,

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
                Positioned(
                  top: 8,
                  left: 8,
                  child: RoundedContainer(
                    child: Text(
                      product.discountPercentage.toString(),
                      style: TextTheme.of(
                        context,
                      ).labelLarge?.copyWith(color: Colors.white),
                    ),
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: RoundedContainer(
                    bgColor: Colors.white,
                    child: Row(
                      children: [
                        Icon(
                          Icons.star,
                          color: Colors.yellow.shade700,
                          size: 16,
                        ),
                        Text(
                          product.discountPercentage.toString(),
                          style: TextTheme.of(context).labelLarge,
                        ),
                      ],
                    ),
                  ),
                ),

                // Positioned(
                //   bottom: 8,
                //   left: 8,
                //   width: 100,
                //   child: Column(
                //     crossAxisAlignment: CrossAxisAlignment.start,
                //     children: [

                //     ],
                //   ),
                // ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0).copyWith(bottom: 0),
            child: Text(
              product.title,
              maxLines: 1,
              style: TextTheme.of(
                context,
              ).titleMedium?.copyWith(overflow: TextOverflow.clip),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              children: [
                Icon(Icons.category_sharp, size: 16),
                Text(
                  '${product.brand} ',

                  style: TextTheme.of(
                    context,
                  ).labelMedium?.copyWith(overflow: TextOverflow.clip),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0).copyWith(top: 4),
            child: Row(
              children: [
                FilledButtonTheme(
                  data: FilledButtonThemeData(
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.red.shade800,
                      foregroundColor: Colors.white,
                    ),
                  ),
                  child: FilledButton(onPressed: () {}, child: Text('Book')),
                ),
                ConstrainedBox(
                  constraints: BoxConstraints.loose(Size.fromWidth(16)),
                  child: SizedBox(width: 20),
                ),
                IconButton.filledTonal(
                  onPressed: () {},
                  icon: Icon(Icons.directions),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
