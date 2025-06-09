// lib/screens/home_tabs_screen.dart

import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'favorite_screen.dart';

class HomeTabsScreen extends StatelessWidget {
  const HomeTabsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2, // dos pestañas: Home y Favoritos
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Mi Tienda'),
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.home), text: 'Home'),
              Tab(icon: Icon(Icons.favorite), text: 'Favoritos'),
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.shopping_cart),
              onPressed: () => Navigator.pushNamed(context, '/cart'),
            ),
          ],
        ),
        body: const TabBarView(
          children: [
            HomeScreen(),       // tu lista de productos
            FavoritesScreen(),  // pantalla de favoritos
          ],
        ),
        floatingActionButton: FloatingActionButton(
          child: const Icon(Icons.add),
          onPressed: () => Navigator.pushNamed(context, '/add'),
        ),
      ),
    );
  }
}
