// lib/models/product.dart

class Media {
  final String url;
  final String type;

  Media({ required this.url, required this.type });

  factory Media.fromJson(Map<String, dynamic> json) => Media(
    url:  json['url']  as String,
    type: json['type'] as String,
  );
}

class Product {
  final String id;
  final String name;
  final String description;
  final double price;
  final int stock;         // ← Nuevo campo
  final List<Media> media;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.stock,
    required this.media,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id:          json['id'].toString(),
      name:        json['name'] as String,
      description: json['description'] as String,
      price:       (json['price'] as num).toDouble(),
      stock:       (json['stock'] as num).toInt(),  // ← Parsear stock
      media:       (json['media'] as List<dynamic>)
          .map((m) => Media.fromJson(m as Map<String, dynamic>))
          .toList(),
    );
  }
}
