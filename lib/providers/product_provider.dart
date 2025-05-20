import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/product.dart';

class ProductProvider with ChangeNotifier {
  List<Product> _products = [];
  List<Product> get products => _products;

  Future<void> fetchProducts() async {
    final response = await http.get(Uri.parse("https://fakestoreapi.com/products"));
    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      _products = data.map((e) => Product.fromJson(e)).toList();
      notifyListeners();
    }
  }

  void addProduct(Product product) {
    _products.add(product);
    notifyListeners();
  }
}