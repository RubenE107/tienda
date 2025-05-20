import 'package:flutter/material.dart';
import '../models/product.dart';

class CartProvider with ChangeNotifier {
  final Map<Product, int> _items = {};
  Map<Product, int> get items => _items;

  void addToCart(Product product) {
    _items.update(product, (quantity) => quantity + 1, ifAbsent: () => 1);
    notifyListeners();
  }

  void updateQuantity(Product product, int cantidad) {
    if (cantidad > 0) {
      _items[product] = cantidad;
    } else {
      _items.remove(product);
    }
    notifyListeners();
  }

  double get total => _items.entries.fold(0, (sum, e) => sum + e.key.price * e.value);

  void clearCart() {
    _items.clear();
    notifyListeners();
  }
}
