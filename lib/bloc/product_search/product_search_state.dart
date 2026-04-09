part of 'product_search_bloc.dart';

sealed class ProductSearchState extends Equatable {
  const ProductSearchState();

  @override
  List<Object> get props => [];
}

final class SearchStateEmpty extends ProductSearchState {}

final class SearchStateNoData extends ProductSearchState {}

final class SearchStateLoadInPending extends ProductSearchState {}

final class SearchStateLoadSuccess extends ProductSearchState {
  final SearchList searchList;
  const SearchStateLoadSuccess({required this.searchList});
  @override
  List<Object> get props => [searchList];
}

final class SearchStateLoadFailure extends ProductSearchState {
  final String message;

  const SearchStateLoadFailure({required this.message});

  @override
  List<Object> get props => [message];
}
