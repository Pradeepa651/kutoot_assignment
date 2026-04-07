import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_developer_assignment_task/bloc/cubit/fast_srcolling_cubit.dart';
import 'package:flutter_developer_assignment_task/bloc/product_bloc/product_bloc.dart';

import '../model/products.dart' show Product, Review;
import '../repo/product_repo.dart' show ProductRepository;

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
        BlocProvider(create: (context) => FastSrcollingCubit()),
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

  void _fechNextProducts(BuildContext context) {
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
              _fechNextProducts(context);
            }
            context.read<FastSrcollingCubit>().updateScrollState(
              isFastScroll(scrollInfo),
            );
            return false;
          },
          child: CustomScrollView(
            slivers: [
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
          BlocBuilder<FastSrcollingCubit, bool>(
            builder: (context, isFastScrolling) {
              return isFastScrolling
                  ? ImagrSkeleton()
                  : Image.network(
                      product.thumbnail,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return const ImagrSkeleton();
                      },
                      width: double.infinity,
                      height: 200,
                      fit: BoxFit.fitHeight,
                    );
            },
          ),
          ListTile(
            title: Text(product.title),
            subtitle: Text('\$${product.description}'),
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

class ImagrSkeleton extends StatelessWidget {
  const ImagrSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 200,
      color: Colors.grey[300],
      child: const Center(),
    );
  }
}

class HorizontalBarPainter extends CustomPainter {
  final double percentage;
  final Color barColor;
  final Color backgroundColor;

  HorizontalBarPainter({
    required this.percentage,
    required this.barColor,
    required this.backgroundColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Paint for the background track
    final bgPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.fill;

    // Paint for the filled value
    final fillPaint = Paint()
      ..color = barColor
      ..style = PaintingStyle.fill;

    // 1. Draw the background track across the full width
    final bgRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Radius.circular(size.height / 2), // Gives rounded corners
    );
    canvas.drawRRect(bgRect, bgPaint);

    // 2. Draw the filled bar based on the percentage
    if (percentage > 0) {
      final fillWidth = size.width * percentage;
      final fillRect = RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, fillWidth, size.height),
        Radius.circular(size.height / 2),
      );
      canvas.drawRRect(fillRect, fillPaint);
    }
  }

  @override
  bool shouldRepaint(covariant HorizontalBarPainter oldDelegate) {
    // Only redraw if the data or colors actually change
    return oldDelegate.percentage != percentage ||
        oldDelegate.barColor != barColor ||
        oldDelegate.backgroundColor != backgroundColor;
  }
}
