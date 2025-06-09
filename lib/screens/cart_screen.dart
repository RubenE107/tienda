// lib/screens/cart_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tienda/providers/cart_provider.dart';
import 'package:tienda/providers/product_provider.dart';
import 'package:tienda/models/product.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    final prodProv = context.read<ProductProvider>();
    final items = cart.items;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Carrito'),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Center(child: Text('Items: ${cart.totalCount}')),
          ),
        ],
      ),
      body: items.isEmpty
          ? const Center(child: Text('El carrito está vacío'))
          : ListView.builder(
        itemCount: items.length,
        itemBuilder: (_, i) {
          final itm = items[i];
          final p = itm.product;

          // Busca la primera media de tipo 'image'
          final imageMedia = p.media.firstWhere(
                (m) => m.type == 'image',
            orElse: () => Media(url: '', type: 'placeholder'),
          );

          final leadingWidget = (imageMedia.url.isNotEmpty)
              ? Image.network(
            '${ProductProvider.baseUrl}${imageMedia.url}',
            width: 50,
            height: 50,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) =>
            const Icon(Icons.broken_image),
          )
              : const Icon(Icons.image_not_supported, size: 50);

          return ListTile(
            leading: leadingWidget,
            title: Text(p.name),
            subtitle: Text(
              '\$${p.price.toStringAsFixed(2)} × ${itm.quantity}',
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.remove_circle_outline),
                  onPressed: () =>
                      context.read<CartProvider>().removeSingle(p),
                ),
                Text('${itm.quantity}'),
                IconButton(
                  icon: const Icon(Icons.add_circle_outline),
                  onPressed: itm.quantity < p.stock
                      ? () => context.read<CartProvider>().addProduct(p)
                      : null,
                ),
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () =>
                      context.read<CartProvider>().removeAll(p),
                ),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Total: \$${cart.totalPrice.toStringAsFixed(2)}',
              style:
              const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: items.isEmpty
                  ? null
                  : () async {
                try {
                  for (final itm in items) {
                    final rem = itm.product.stock - itm.quantity;
                    await prodProv.updateStockInDB(
                        itm.product.id, rem);
                  }
                  context.read<CartProvider>().clearCart();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Compra realizada con éxito!')),
                  );
                  Navigator.pop(context);
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error al comprar: $e')),
                  );
                }
              },
              child: const Text('Comprar'),
            ),
          ],
        ),
      ),
    );
  }
}
