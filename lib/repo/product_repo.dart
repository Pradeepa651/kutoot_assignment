


import 'package:dio/dio.dart';
import 'package:flutter_developer_assignment_task/model/products.dart' show Products;


final dio = Dio();
class ProductRepository {
  Future<Products> fetchProducts({int limit = 30, int skip = 0}) async {
    try {
      final response = await dio.get('https://dummyjson.com/products', queryParameters: {'limit': limit, 'skip': skip});
      if (response.statusCode == 200) {
        final productsData = response.data;
        return Products.fromMap(productsData);
      } else {
        throw Exception('Failed to load products');
      }
    } catch (e) {
      throw Exception('Failed to load products: $e');
    }
  }
}
