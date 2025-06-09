// lib/screens/favorites_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:tienda/providers/favorite_provider.dart';
import 'package:tienda/providers/product_provider.dart';
import 'package:tienda/models/product.dart';
import 'package:tienda/models/product.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final favProv   = context.watch<FavoritesProvider>();
    final products  = context.watch<ProductProvider>().products;
    // Filtra sólo los favoritos
    final favs      = products.where((p) => favProv.isFavorite(p.id)).toList();

    if (favs.isEmpty) {
      return const Center(child: Text('No tienes favoritos aún'));
    }

    return ListView.builder(
      itemCount: favs.length,
      itemBuilder: (context, i) {
        final p = favs[i];
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

        return ListTile(
          leading: leading,
          title: Text(p.name),
          subtitle: Text('\$${p.price.toStringAsFixed(2)}'),
          trailing: IconButton(
            icon: const Icon(Icons.favorite, color: Colors.red),
            tooltip: 'Quitar de favoritos',
            onPressed: () {
              // Al tocar, quita este producto de favoritos
              favProv.toggleFavorite(p.id, context);
            },
          ),
          onTap: () {
            // Puedes navegar al detalle si lo deseas
            Navigator.pushNamed(context, '/detail', arguments: p.id);
          },
        );
      },
    );
  }
}
