// lib/main.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:tienda/providers/product_provider.dart';
import 'package:tienda/providers/cart_provider.dart';
import 'package:tienda/providers/cuenta_provider.dart';
import 'package:tienda/providers/favorite_provider.dart';

import 'package:tienda/screens/home_tabs_screem.dart';
import 'package:tienda/screens/add_product_screen.dart';
import 'package:tienda/screens/cart_screen.dart';
import 'package:tienda/screens/login_screen.dart';
import 'package:tienda/screens/product_detail_screen.dart';

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
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProxyProvider<AuthProvider, FavoritesProvider>(
          create: (ctx) => FavoritesProvider(ctx.read<AuthProvider>()),
          update: (ctx, auth, prev) => FavoritesProvider(auth),
        ),
      ],
      child: MaterialApp(
        title: 'Mi Tienda',
        initialRoute: '/',
        routes: {
          '/':      (c) => const HomeTabsScreen(),
          '/add':   (c) => const AddProductScreen(),
          '/cart':  (c) => const CartScreen(),
          '/login': (c) => const LoginScreen(),
        },
        onGenerateRoute: (settings) {
          if (settings.name == '/detail' && settings.arguments is String) {
            final id = settings.arguments as String;
            return MaterialPageRoute(
              builder: (_) => ProductDetailScreen(productId: id),
            );
          }
          return null;
        },
      ),
    );
  }
}
