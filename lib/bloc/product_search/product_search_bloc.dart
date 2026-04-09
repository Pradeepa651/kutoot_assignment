import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:stream_transform/stream_transform.dart' show RateLimit, Switch;

import '../../model/search_product.dart' show SearchList;
import '../../repo/product_repo.dart' show ProductRepository;

part 'product_search_event.dart';
part 'product_search_state.dart';

EventTransformer<Event> debounce<Event>(Duration duration) {
  return (events, mapper) => events.debounce(duration).switchMap(mapper);
}

class ProductSearchBloc extends Bloc<ProductSearchEvent, ProductSearchState> {
  final ProductRepository productRepository;
  ProductSearchBloc(this.productRepository) : super(SearchStateEmpty()) {
    on<SearchTextChanged>(
      _onSearchTextChanged,
      transformer: debounce(const Duration(milliseconds: 300)),
    );
  }

  void _onSearchTextChanged(
    SearchTextChanged event,
    Emitter<ProductSearchState> emit,
  ) async {
    final query = event.query;
    if (query.isEmpty) {
      emit(SearchStateEmpty());
      return;
    }
    if (query.trim().isEmpty) {
      emit(SearchStateNoData());
      return;
    }
    emit(SearchStateLoadInPending());
    try {
      final searchList = await productRepository.searchProducts(query: query);
      emit(SearchStateLoadSuccess(searchList: searchList));
    } catch (e) {
      emit(SearchStateLoadFailure(message: 'Something went wrong!'));
    }
  }
}
