// lib/providers/cart_provider.dart

import 'package:flutter/material.dart';
import 'package:tienda/models/product.dart';

class CartItem {
  final Product product;
  int quantity;
  CartItem({ required this.product, this.quantity = 1 });
}

class CartProvider with ChangeNotifier {
  final Map<String, CartItem> _items = {};

  List<CartItem> get items => _items.values.toList();

  void addProduct(Product product) {
    if (_items.containsKey(product.id)) {
      _items[product.id]!.quantity++;
    } else {
      _items[product.id] = CartItem(product: product);
    }
    notifyListeners();
  }

  void removeSingle(Product product) {
    if (!_items.containsKey(product.id)) return;
    if (_items[product.id]!.quantity > 1) {
      _items[product.id]!.quantity--;
    } else {
      _items.remove(product.id);
    }
    notifyListeners();
  }

  void removeAll(Product product) {
    _items.remove(product.id);
    notifyListeners();
  }

  void clearCart() {
    _items.clear();
    notifyListeners();
  }

  double get totalPrice => _items.values
      .fold(0.0, (sum, item) => sum + item.product.price * item.quantity);

  int get totalCount =>
      _items.values.fold(0, (sum, item) => sum + item.quantity);
}
