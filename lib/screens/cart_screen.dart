import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';

class CartScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Carrito de compras')),
      body: cartProvider.items.isEmpty
          ? const Center(child: Text('Tu carrito está vacío'))
          : Column(
              children: [
                Expanded(
                  child: ListView(
                    children: cartProvider.items.entries.map((entry) {
                      final product = entry.key;
                      final quantity = entry.value;

                      return ListTile(
                        leading: Image.network(product.image, width: 50),
                        title: Text(product.title),
                        subtitle: Text('Precio: \$${product.price.toStringAsFixed(2)}'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.remove),
                              onPressed: () {
                                cartProvider.updateQuantity(product, quantity - 1);
                              },
                            ),
                            Text(quantity.toString()),
                            IconButton(
                              icon: const Icon(Icons.add),
                              onPressed: () {
                                cartProvider.updateQuantity(product, quantity + 1);
                              },
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Text('Total: \$${cartProvider.total.toStringAsFixed(2)}', style: const TextStyle(fontSize: 20)),
                      const SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: () {
                          cartProvider.clearCart();
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Compra confirmada')));
                          Navigator.pop(context);
                        },
                        child: const Text('Confirmar compra'),
                      ),
                    ],
                  ),
                )
              ],
            ),
    );
  }
}
