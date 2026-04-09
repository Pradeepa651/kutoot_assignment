class SearchList {
  final List<Product> products;

  SearchList({required this.products});

  factory SearchList.fromMap(Map<String, dynamic> json) => SearchList(
    products: List<Product>.from(
      json["products"].map((x) => Product.fromMap(x)),
    ),
  );

  Map<String, dynamic> toMap() => {
    "products": List<dynamic>.from(products.map((x) => x.toMap())),
  };
}

class Product {
  final int id;
  final String title;

  Product({required this.id, required this.title});

  factory Product.fromMap(Map<String, dynamic> json) =>
      Product(id: json["id"], title: json["title"]);

  Map<String, dynamic> toMap() => {"id": id, "title": title};
}
