// lib/providers/product_provider.dart

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:tienda/models/product.dart';

class ProductProvider with ChangeNotifier {
  /// Haz público el baseUrl para que otras clases lo puedan usar
  static const String baseUrl = 'https://kk6q1sz1-3000.usw3.devtunnels.ms';

  List<Product> _products = [];
  List<Product> get products => _products;

  /// GET https://.../productos
  Future<void> fetchProducts() async {
    final uri = Uri.parse('$baseUrl/productos');
    final res = await http.get(uri);
    if (res.statusCode != 200) {
      throw Exception('Error ${res.statusCode} al cargar productos');
    }
    final decoded = json.decode(res.body);
    List<dynamic> lista;
    if (decoded is Map<String, dynamic> && decoded['productos'] is List) {
      lista = decoded['productos'] as List<dynamic>;
    } else if (decoded is List) {
      lista = decoded;
    } else {
      throw Exception('Formato JSON inesperado');
    }
    _products = lista
        .map((p) => Product.fromJson(p as Map<String, dynamic>))
        .toList();
    notifyListeners();
  }

  /// Añade localmente un producto (para pruebas o mock)
  void addProduct(Product product) {
    _products.add(product);
    notifyListeners();
  }

  /// POST https://.../productos
  Future<void> createProductInDB(Product newProduct) async {
    final uri = Uri.parse('$baseUrl/productos');
    final res = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'id': newProduct.id,
        'name': newProduct.name,
        'description': newProduct.description,
        'price': newProduct.price,
        'stock': newProduct.stock,
        'media': newProduct.media
            .map((m) => {'url': m.url, 'type': m.type})
            .toList(),
      }),
    );
    if (res.statusCode != 201) {
      throw Exception('Error ${res.statusCode} al crear producto');
    }
    await fetchProducts();
  }

  /// PATCH https://.../productos/{id}
  Future<void> updateStockInDB(String productId, int newStock) async {
    final uri = Uri.parse('$baseUrl/productos/$productId');
    final res = await http.patch(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'stock': newStock}),
    );
    if (res.statusCode != 200) {
      throw Exception('Error ${res.statusCode} al actualizar stock');
    }
    // Actualiza localmente
    final idx = _products.indexWhere((p) => p.id == productId);
    if (idx != -1) {
      final p = _products[idx];
      _products[idx] = Product(
        id: p.id,
        name: p.name,
        description: p.description,
        price: p.price,
        stock: newStock,
        media: p.media,
      );
      notifyListeners();
    }
  }
}
