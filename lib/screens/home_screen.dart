import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:tienda/providers/product_provider.dart';
import 'package:tienda/providers/favorite_provider.dart';
import 'package:tienda/models/product.dart';
import 'package:tienda/models/product.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    try {
      await context.read<ProductProvider>().fetchProducts();
    } catch (e) {
      _error = e.toString();
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final products = context.watch<ProductProvider>().products;
    final favProv  = context.watch<FavoritesProvider>();

    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (_error != null) {
      return Scaffold(body: Center(child: Text('Error: $_error')));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Productos'),
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart),
            onPressed: () => Navigator.pushNamed(context, '/cart'),
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: products.length,
        itemBuilder: (_, i) {
          final p = products[i];
          final imageMedia = p.media.firstWhere(
                (m) => m.type == 'image',
            orElse: () => Media(url: '', type: 'placeholder'),
          );
          final leading = imageMedia.url.isNotEmpty
              ? Image.network(
            '${ProductProvider.baseUrl}${imageMedia.url}',
            width: 50, height: 50, fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => const Icon(Icons.broken_image),
          )
              : const Icon(Icons.image_not_supported, size: 50);

          final isFav = favProv.isFavorite(p.id);

          return ListTile(
            leading: leading,
            title: Text(p.name),
            subtitle: Text('\$${p.price.toStringAsFixed(2)}'),
            trailing: IconButton(
              icon: Icon(isFav ? Icons.favorite : Icons.favorite_border,
                  color: isFav ? Colors.red : null),
              onPressed: () => favProv.toggleFavorite(p.id, context),
            ),
            onTap: () => Navigator.pushNamed(
              context, '/detail', arguments: p.id,
            ),
          );
        },
      ),
      //floatingActionButton: FloatingActionButton(child: const Icon(Icons.add), onPressed: () => Navigator.pushNamed(context, '/add'),),
    );
  }
}
