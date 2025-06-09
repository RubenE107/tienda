// lib/providers/auth_provider.dart

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:tienda/models/user.dart';
import 'package:tienda/providers/product_provider.dart';

class AuthProvider with ChangeNotifier {
  User? _user;
  User? get user => _user;
  bool get isLoggedIn => _user != null;

  Future<void> login(String email, String password) async {
    final uri = Uri.parse('${ProductProvider.baseUrl}/login');
    final res = await http.post(uri,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'email': email, 'password': password}));
    if (res.statusCode == 200) {
      _user = User.fromJson(json.decode(res.body));
      notifyListeners();
    } else {
      throw Exception('Login fallido');
    }
  }

  void logout() {
    _user = null;
    notifyListeners();
  }

  Future<void> updateFavorites(List<String> favs) async {
    if (_user == null) return;
    final uri =
    Uri.parse('${ProductProvider.baseUrl}/usuarios/${_user!.id}');
    final res = await http.patch(uri,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'favorites': favs}));
    if (res.statusCode == 200) {
      _user!.favorites = favs;
      notifyListeners();
    } else {
      throw Exception('Error actualizando favoritos');
    }
  }

  Future<void> updateCart(List<CartItemData> cartItems) async {
    if (_user == null) return;
    final uri =
    Uri.parse('${ProductProvider.baseUrl}/usuarios/${_user!.id}');
    final res = await http.patch(uri,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'cart': cartItems.map((e) => e.toJson()).toList()
        }));
    if (res.statusCode == 200) {
      _user!.cart = cartItems;
      notifyListeners();
    } else {
      throw Exception('Error actualizando carrito en DB');
    }
  }
}
