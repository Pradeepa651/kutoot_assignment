part of 'product_bloc.dart';

@immutable
sealed class ProductEvent extends Equatable {}

final class ProductFetched extends ProductEvent {
  ProductFetched({this.limit = 30});
  final int limit ;
  @override
  List<Object?> get props => [limit];
}
final class ProductRefreshed extends ProductEvent {
  ProductRefreshed({this.limit = 30});
  final int limit ;
  @override
  List<Object?> get props => [limit];
}
  
  

