import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/product.dart';
import '../providers/cart_provider.dart';

class ProductDetailScreen extends StatelessWidget {
  final Product product;

  const ProductDetailScreen({required this.product});

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(product.title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Image.network(
              product.image,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) =>
                  const Icon(Icons.broken_image, size: 100),
            ),  

            const SizedBox(height: 20),
            Text(product.title, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Text('\$${product.price.toStringAsFixed(2)}', style: TextStyle(fontSize: 18)),
            const SizedBox(height: 10),
            Expanded(child: SingleChildScrollView(child: Text(product.description))),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                cartProvider.addToCart(product);
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Producto agregado al carrito')));
              },
              child: const Text('Agregar al carrito'),
            ),
          ],
        ),
      ),
    );
  }
}
