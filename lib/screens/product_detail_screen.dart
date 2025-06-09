import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';

import 'package:tienda/models/product.dart';
import 'package:tienda/providers/product_provider.dart';
import 'package:tienda/providers/cart_provider.dart';
import 'package:tienda/providers/cuenta_provider.dart';
import 'package:tienda/providers/favorite_provider.dart';
import 'package:tienda/models/product.dart';
import 'package:tienda/models/user.dart';

class ProductDetailScreen extends StatefulWidget {
  final String productId;
  const ProductDetailScreen({Key? key, required this.productId})
      : super(key: key);

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  late Future<Product> _futureProduct;
  late PageController _pageController;
  late List<VideoPlayerController?> _videoControllers;
  late List<double> _volumes;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _futureProduct = _loadProduct();
    _pageController = PageController();
  }

  Future<Product> _loadProduct() async {
    final prov = context.read<ProductProvider>();
    await prov.fetchProducts();
    final p = prov.products.firstWhere((p) => p.id == widget.productId);
    // inicializa vídeos y volúmenes
    _videoControllers = p.media.map((m) {
      if (m.type == 'video') {
        final vc = VideoPlayerController.network(
          '${ProductProvider.baseUrl}${m.url}',
        )..initialize().then((_) => setState(() {}));
        return vc;
      }
      return null;
    }).toList();
    _volumes = List<double>.filled(p.media.length, 1.0);
    return p;
  }

  @override
  void dispose() {
    for (final vc in _videoControllers.whereType<VideoPlayerController>()) {
      vc.dispose();
    }
    _pageController.dispose();
    super.dispose();
  }

  void _onVerticalDrag(DragEndDetails d) {
    final v = d.primaryVelocity ?? 0;
    if (v < 0 && _currentPage < _videoControllers.length - 1) {
      _pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.ease);
    } else if (v > 0 && _currentPage > 0) {
      _pageController.previousPage(duration: const Duration(milliseconds: 300), curve: Curves.ease);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cartProv    = context.read<CartProvider>();
    final authProv    = context.read<AuthProvider>();
    final favProv     = context.read()<FavoritesProvider>();

    return FutureBuilder<Product>(
      future: _futureProduct,
      builder: (_, snap) {
        if (!snap.hasData) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        final p = snap.data!;
        final inStock = p.stock > 0;
        final isFav   = favProv.isFavorite(p.id);

        return Scaffold(
          appBar: AppBar(
            title: Text(p.name),
            actions: [
              //IconButton(
                //icon: Icon(isFav ? Icons.favorite : Icons.favorite_border,
                    //color: isFav ? Colors.red : null),
                //onPressed: () => favProv.toggleFavorite(p.id, context),
              //),
              IconButton(
                icon: Icon(isFav ? Icons.favorite : Icons.favorite_border,
                    color: isFav ? Colors.red : null),
                onPressed: () => favProv.toggleFavorite(p.id, context),
              ),
              IconButton(
                icon: const Icon(Icons.shopping_cart),
                onPressed: () => Navigator.pushNamed(context, '/cart'),
              ),
            ],
          ),
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                SizedBox(
                  height: 300,
                  child: GestureDetector(
                    onVerticalDragEnd: _onVerticalDrag,
                    child: PageView.builder(
                      controller: _pageController,
                      itemCount: p.media.length,
                      onPageChanged: (i) => setState(() => _currentPage = i),
                      itemBuilder: (_, i) {
                        final m = p.media[i];
                        final url = '${ProductProvider.baseUrl}${m.url}';
                        if (m.type == 'image') {
                          return Image.network(url, fit: BoxFit.cover, width: double.infinity);
                        } else {
                          final vc = _videoControllers[i]!;
                          if (!vc.value.isInitialized) {
                            return const Center(child: CircularProgressIndicator());
                          }
                          return Column(children: [
                            Expanded(
                              child: Stack(alignment: Alignment.center, children: [
                                AspectRatio(aspectRatio: vc.value.aspectRatio, child: VideoPlayer(vc)),
                                IconButton(
                                  iconSize: 48,
                                  color: Colors.white70,
                                  icon: Icon(vc.value.isPlaying ? Icons.pause_circle : Icons.play_circle),
                                  onPressed: () => setState(() {
                                    vc.value.isPlaying ? vc.pause() : vc.play();
                                  }),
                                ),
                              ]),
                            ),
                            Row(children: [
                              const Icon(Icons.volume_down),
                              Expanded(
                                child: Slider(
                                  min: 0, max: 1, value: _volumes[i],
                                  onChanged: (v) => setState(() {
                                    _volumes[i] = v;
                                    vc.setVolume(v);
                                  }),
                                ),
                              ),
                              const Icon(Icons.volume_up),
                            ]),
                          ]);
                        }
                      },
                    ),
                  ),
                ),
                if (p.media.length > 1)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(p.media.length, (j) {
                        return Container(
                          width: 8, height: 8,
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: j == _currentPage ? Colors.blue : Colors.grey,
                          ),
                        );
                      }),
                    ),
                  ),
                const SizedBox(height: 16),
                Text(p.description),
                const SizedBox(height: 8),
                Text('Precio: \$${p.price.toStringAsFixed(2)}'),
                const SizedBox(height: 8),
                Text(inStock ? 'Disponibles: ${p.stock}' : 'Agotado',
                    style: TextStyle(fontWeight: FontWeight.bold, color: inStock ? Colors.green : Colors.red)),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: !inStock
                      ? null
                      : () async {
                    if (!authProv.isLoggedIn) {
                      await Navigator.pushNamed(context, '/login');
                      if (!authProv.isLoggedIn) return;
                    }
                    cartProv.addProduct(p);
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Producto agregado al carrito')));
                  },
                  child: Text(inStock ? 'Agregar al carrito' : 'Sin stock'),
                ),
              ]),
            ),
          ),
        );
      },
    );
  }
}
