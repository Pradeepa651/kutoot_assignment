
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart' show immutable;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_developer_assignment_task/model/products.dart';

import '../../repo/product_repo.dart' show ProductRepository;

part 'product_event.dart';
part 'product_state.dart';

class ProductBloc extends Bloc<ProductEvent, ProductState> {

  final ProductRepository productRepository;
  ProductBloc({required this.productRepository}) : super(ProductState(
    skip: 0,
    apiStatus: ApiStatus.initial,
    products: [], 
  )) {
    on<ProductFetched>(_onProductFetched);
    on<ProductRefreshed>(_onProductRefreshed);
  }

  void _onProductFetched(ProductFetched event, Emitter<ProductState> emit) async {
    emit(state.copyWith(apiStatus: ApiStatus.loading));
    try {
     final productData =  await productRepository.fetchProducts(limit: event.limit, skip: state.skip);
      final products = List<Product>.from(state.products)..addAll(productData.products);
      emit(state.copyWith(apiStatus: ApiStatus.success, products: products, totalCount: productData.total, skip: state.skip + event.limit, hasMaxReached: products.length >= productData.total));

    } catch (e) {
      emit(state.copyWith(apiStatus: ApiStatus.error, errorMessage: e.toString()));
    }
  }

  void _onProductRefreshed(ProductRefreshed event, Emitter<ProductState> emit) async {
    emit(state.copyWith(apiStatus: ApiStatus.refresh));
    try {
     final productData =  await productRepository.fetchProducts(limit: event.limit, skip: 0);
      emit(state.copyWith(apiStatus: ApiStatus.success, products: productData.products, totalCount: productData.total, skip: event.limit, hasMaxReached: productData.products.length >= productData.total));

    } catch (e) {
      emit(state.copyWith(apiStatus: ApiStatus.error, errorMessage: e.toString()));
    }
  }
}
