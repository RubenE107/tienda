import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tienda/screens/add_product_screen.dart';
import '../providers/product_provider.dart';
import '../providers/cart_provider.dart';
import '../screens/product_detail_screen.dart';
import '../screens/cart_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    Provider.of<ProductProvider>(context, listen: false).fetchProducts();
  }

  @override
  Widget build(BuildContext context) {
    final productProvider = Provider.of<ProductProvider>(context);
    final cartProvider = Provider.of<CartProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Tienda'),
        //backgroundColor: const Color.fromARGB(255, 255, 255, 255),
        actions: [
          IconButton(
            icon: Icon(Icons.shopping_cart),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => CartScreen()),
              );
            },
          ),
        ],
      ),
      body:
          productProvider.products.isEmpty
              ? Center(child: CircularProgressIndicator())
              : ListView.builder(
                padding: EdgeInsets.all(8.0),
                itemExtent: 100,
                itemCount: productProvider.products.length,
                itemBuilder: (context, index) {
                  final product = productProvider.products[index];
                  return Container(
                    margin: EdgeInsets.symmetric(vertical: 1.0),
                    decoration: BoxDecoration(
                      border: Border.all(color: const Color.fromARGB(255, 111, 111, 111)),
                      borderRadius: BorderRadius.circular(8),
                      //color: const Color.fromARGB(255, 0, 0, 0),


                    ),



                    child: ListTile(
                      leading: Image.network(
                        product.image,
                        width: 50,
                        height: 50,
                      ),
                      title: Text(product.title),
                      subtitle: Text('\$${product.price.toStringAsFixed(2)}'),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ProductDetailScreen(product: product),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => AddProductScreen()),
          );
        },
      ),
    );
  }
}
