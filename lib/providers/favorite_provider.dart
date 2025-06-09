// lib/providers/favorites_provider.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tienda/providers/cuenta_provider.dart';

class FavoritesProvider with ChangeNotifier {
  List<String> get favorites =>
      _auth.user?.favorites ?? [];

  bool isFavorite(String productId) =>
      favorites.contains(productId);

  void toggleFavorite(String productId, BuildContext context) {
    final favs = List<String>.from(favorites);
    if (favs.contains(productId)) favs.remove(productId);
    else favs.add(productId);

    // actualiza en AuthProvider (y en backend)
    context.read<AuthProvider>().updateFavorites(favs);
  }

  final AuthProvider _auth;
  FavoritesProvider(this._auth);
}
