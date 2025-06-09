import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tienda/providers/product_provider.dart';
import 'package:tienda/providers/cart_provider.dart';
import 'package:tienda/screens/home_screen.dart';
import 'package:tienda/screens/add_product_screen.dart';
import 'package:tienda/screens/cart_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ProductProvider()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
      ],
      child: MaterialApp(
        title: 'Mi Tienda',
        // ← Aquí configuramos rutas en lugar de usar `home`
        initialRoute: '/',
        routes: {
          '/':    (context) => const HomeScreen(),
          '/add': (context) => const AddProductScreen(),
          '/cart':(context) => const CartScreen(),
        },
      ),
    );
  }
}
