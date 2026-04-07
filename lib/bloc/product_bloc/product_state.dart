



part of 'product_bloc.dart';

enum ApiStatus {
  initial,
  loading,
  success,
  error,
  refresh,
  unAuthorized,
  updated,
}

class ProductState extends Equatable {

  final bool hasMaxReached;
  final int skip;
  final String? errorMessage;
  final int totalCount;
   final ApiStatus apiStatus;
   final List<Product> products;

  const ProductState({
    this.hasMaxReached = false,
    required this.skip,
    this.errorMessage,
     this.totalCount = 0,
    required this.apiStatus,
    required this.products,
  });
  
  @override
  List<Object> get props {
    return [
      hasMaxReached,
      skip,
      ?errorMessage,
      totalCount,
      apiStatus,
      products,
    ];
  }

  ProductState copyWith({
    bool? hasMaxReached,
    int? skip,
    String? errorMessage,
    int? totalCount,
    ApiStatus? apiStatus,
    List<Product>? products,
  }) {
    return ProductState(
      hasMaxReached: hasMaxReached ?? this.hasMaxReached,
      skip: skip ?? this.skip,
      errorMessage: errorMessage ?? this.errorMessage,
      totalCount: totalCount ?? this.totalCount,
      apiStatus: apiStatus ?? this.apiStatus,
      products: products ?? this.products,
    );
  }


}


