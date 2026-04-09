part of 'product_search_bloc.dart';

sealed class ProductSearchEvent extends Equatable {
  const ProductSearchEvent();

  @override
  List<Object> get props => [];
}

final class SearchTextChanged extends ProductSearchEvent {
  final String query;

  const SearchTextChanged({required this.query});
  @override
  List<Object> get props => [query];
}
