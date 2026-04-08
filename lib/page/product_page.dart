import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_developer_assignment_task/bloc/cubit/fast_scrolling_cubit.dart';
import 'package:flutter_developer_assignment_task/bloc/internet_connection_cubit/internet_connection_cubit.dart';
import 'package:flutter_developer_assignment_task/bloc/product_bloc/product_bloc.dart';

import '../model/products.dart' show Product, Review;
import '../repo/product_repo.dart' show ProductRepository;
import '../utils/custom_painter/horizontal_bar_painter.dart';
import '../utils/widgets/image_skeleton.dart' show ImageSkeleton;

class ProductPage extends StatelessWidget {
  const ProductPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) =>
              ProductBloc(productRepository: context.read<ProductRepository>())
                ..add(ProductFetched()),
        ),
        BlocProvider(create: (context) => FastScrollingCubit()),
      ],
      child: Scaffold(
        appBar: AppBar(title: const Text('Products')),

        body: ProductListView(),
      ),
    );
  }
}

class ProductListView extends StatelessWidget {
  const ProductListView({super.key});

  void _fetchNextProducts(BuildContext context) {
    if (context.read<ProductBloc>().state.apiStatus != ApiStatus.loading &&
        !context.read<ProductBloc>().state.hasMaxReached) {
      context.read<ProductBloc>().add(ProductFetched());
    }
  }

  void _refreshProducts(BuildContext context) {
    context.read<ProductBloc>().add(ProductRefreshed());
  }

  bool isFastScroll(ScrollUpdateNotification scrollInfo) {
    if (scrollInfo.scrollDelta == null) return false;
    return scrollInfo.scrollDelta!.abs() > 35;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: RefreshIndicator(
        onRefresh: () => Future.sync(() => _refreshProducts(context)),
        child: NotificationListener<ScrollUpdateNotification>(
          onNotification: (scrollInfo) {
            if (scrollInfo.metrics.pixels >=
                scrollInfo.metrics.maxScrollExtent - 200) {
              _fetchNextProducts(context);
            }
            context.read<FastScrollingCubit>().updateScrollState(
              isFastScroll(scrollInfo),
            );
            return false;
          },
          child: CustomScrollView(
            slivers: [
              BlocConsumer<InternetConnectionCubit, InternetConnectionState>(
                listener: (context, state) {
                  if (state is InternetConnectionConnected) {
                    context.read<ProductBloc>().add(ProductRefreshed());
                  }
                },
                builder: (context, state) {
                  if (state is InternetConnectionDisconnected) {
                    return const PinnedHeaderSliver(
                      child: ColoredBox(
                        color: Colors.white,
                        child: Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.warning, color: Colors.red),
                              SizedBox(width: 8),
                              Text('You are offline'),
                            ],
                          ),
                        ),
                      ),
                    );
                  }
                  return SliverToBoxAdapter();
                },
              ),
              BlocBuilder<ProductBloc, ProductState>(
                builder: (context, state) {
                  if (state.apiStatus == ApiStatus.loading &&
                      state.products.isEmpty) {
                    return const SliverFillRemaining(
                      child: Center(
                        child: RepaintBoundary(
                          child: CircularProgressIndicator(),
                        ),
                      ),
                    );
                  } else if (state.apiStatus == ApiStatus.error &&
                      state.products.isEmpty) {
                    return SliverFillRemaining(
                      child: RepaintBoundary(
                        child: Center(
                          child: Text('Error: ${state.errorMessage}'),
                        ),
                      ),
                    );
                  } else if (state.products.isEmpty) {
                    return const SliverFillRemaining(
                      child: Center(child: Text('No products available')),
                    );
                  } else {
                    return SliverList.builder(
                      itemBuilder: (context, index) {
                        return ProductView(product: state.products[index]);
                      },
                      itemCount: state.products.length,
                    );
                  }
                },
              ),

              BlocBuilder<ProductBloc, ProductState>(
                builder: (context, state) {
                  if (state.apiStatus == ApiStatus.loading &&
                      state.products.isNotEmpty) {
                    return const SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        child: Center(
                          child: RepaintBoundary(
                            child: CircularProgressIndicator(),
                          ),
                        ),
                      ),
                    );
                  } else if (state.hasMaxReached) {
                    return const SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        child: Center(child: Text('No more products')),
                      ),
                    );
                  } else if (state.apiStatus != ApiStatus.error &&
                      state.products.isNotEmpty) {
                    return SliverToBoxAdapter(
                      child: Column(
                        children: [
                          ListTile(
                            title: const Text('Something went wrong!'),
                            subtitle: const Text('Refresh to try again'),
                            leading: const Icon(Icons.refresh),
                            onTap: () {
                              context.read<ProductBloc>().add(
                                ProductRefreshed(),
                              );
                            },
                          ),
                        ],
                      ),
                    );
                  }

                  return const SliverToBoxAdapter();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ProductView extends StatelessWidget {
  const ProductView({super.key, required this.product});

  final Product product;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          BlocBuilder<FastScrollingCubit, bool>(
            builder: (context, isFastScrolling) {
              return isFastScrolling
                  ? ImageSkeleton()
                  : Image.network(
                      product.thumbnail,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return const ImageSkeleton();
                      },
                      errorBuilder: (context, error, stackTrace) =>
                          const ImageSkeleton(),
                      width: double.infinity,

                      height: 200,
                      fit: BoxFit.fitHeight,
                    );
            },
          ),
          ListTile(
            title: Text(product.title),
            subtitle: Text(product.description),
          ),
          Padding(
            padding: const EdgeInsets.all(4.0).copyWith(left: 16),
            child: Text('Review', style: TextTheme.of(context).titleMedium),
          ),

          ...product.reviews
              .take(3)
              .map((review) => ReviewListView(review: review)),
        ],
      ),
    );
  }
}

class ReviewListView extends StatelessWidget {
  const ReviewListView({super.key, required this.review});

  final Review review;
  Color _getColorForRating(int stars) {
    if (stars >= 4) return Colors.green.shade400;
    if (stars == 3) return Colors.amber.shade400;
    return Colors.red.shade400;
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      dense: true,
      title: Text(review.reviewerName),
      leading: CircleAvatar(
        child: Text(
          review.reviewerName.isNotEmpty ? review.reviewerName[0] : '?',
        ),
      ),
      subtitle: SizedBox(
        height: 8, // Thickness of the bar
        child: CustomPaint(
          painter: HorizontalBarPainter(
            percentage: review.rating / 5.0,
            barColor: _getColorForRating(review.rating),
            backgroundColor: Colors.grey.shade200,
          ),
        ),
      ),
    );
  }
}
