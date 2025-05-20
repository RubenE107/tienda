import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/product_provider.dart';
import 'providers/cart_provider.dart';
import 'screens/home_screen.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ProductProvider()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        
        
        title: 'Tienda',

        // theme: ThemeData(
        //   scaffoldBackgroundColor: const Color.fromARGB(255, 255, 0, 0),
          
          
        // ),
        home: HomeScreen(),
      ),
    );
  }
}
//https://unsplash.com
//https://picsum.photos
// https://via.placeholder.com
