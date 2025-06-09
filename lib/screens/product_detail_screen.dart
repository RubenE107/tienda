// lib/screens/product_detail_screen.dart

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:provider/provider.dart';
import 'package:tienda/models/product.dart';
import 'package:tienda/providers/cart_provider.dart';
import 'package:tienda/providers/product_provider.dart';

class ProductDetailScreen extends StatefulWidget {
  final Product product;
  const ProductDetailScreen({Key? key, required this.product})
      : super(key: key);

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  late final PageController _pageController;
  late final List<VideoPlayerController?> _videoControllers;
  late final List<double> _volumes;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();

    final media = widget.product.media;
    _pageController = PageController();

    // 1) Inicializa controladores de vídeo (null si es imagen)
    _videoControllers = media.map((m) {
      if (m.type == 'video') {
        final vc = VideoPlayerController.network(
          '${ProductProvider.baseUrl}${m.url}',
        )..initialize().then((_) => setState(() {}));
        return vc;
      }
      return null;
    }).toList();

    // 2) Volúmenes iniciales a tope (1.0) para cada media
    _volumes = List<double>.filled(media.length, 1.0);
  }

  @override
  void dispose() {
    for (final vc in _videoControllers.whereType<VideoPlayerController>()) {
      vc.dispose();
    }
    _pageController.dispose();
    super.dispose();
  }

  // 3) Swipe vertical: subir/bajar página
  void _onVerticalDrag(DragEndDetails details) {
    final velocity = details.primaryVelocity ?? 0;
    if (velocity < 0 && _currentPage < widget.product.media.length - 1) {
      _pageController.nextPage(
          duration: const Duration(milliseconds: 300), curve: Curves.ease);
    } else if (velocity > 0 && _currentPage > 0) {
      _pageController.previousPage(
          duration: const Duration(milliseconds: 300), curve: Curves.ease);
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.product;
    final inStock = p.stock > 0;

    return Scaffold(
      appBar: AppBar(title: Text(p.name)),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- Carrusel con PageView + GestureDetector ---
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

                      // 3.1) Imagen
                      if (m.type == 'image') {
                        return Image.network(
                          url,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          errorBuilder: (_, __, ___) =>
                          const Center(child: Icon(Icons.broken_image)),
                        );
                      }

                      //  Vídeo con play/pause + slider de volumen
                      final vc = _videoControllers[i]!;
                      if (!vc.value.isInitialized) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      return Column(
                        children: [
                          Expanded(
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                AspectRatio(
                                  aspectRatio: vc.value.aspectRatio,
                                  child: VideoPlayer(vc),
                                ),
                                IconButton(
                                  iconSize: 48,
                                  color: Colors.white70,
                                  icon: Icon(vc.value.isPlaying
                                      ? Icons.pause_circle
                                      : Icons.play_circle),
                                  onPressed: () {
                                    setState(() {
                                      vc.value.isPlaying ? vc.pause() : vc.play();
                                    });
                                  },
                                ),
                              ],
                            ),
                          ),
                          // 3.3) Control de volumen
                          Row(
                            children: [
                              const Icon(Icons.volume_down),
                              Expanded(
                                child: Slider(
                                  min: 0,
                                  max: 1,
                                  value: _volumes[i],
                                  onChanged: (v) {
                                    setState(() {
                                      _volumes[i] = v;
                                      vc.setVolume(v);
                                    });
                                  },
                                ),
                              ),
                              const Icon(Icons.volume_up),
                            ],
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),

              // 4) Indicadores
              if (p.media.length > 1)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      p.media.length,
                          (j) => Container(
                        width: 8,
                        height: 8,
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: j == _currentPage ? Colors.blue : Colors.grey,
                        ),
                      ),
                    ),
                  ),
                ),

              const SizedBox(height: 16),
              Text(p.description),
              const SizedBox(height: 8),
              Text('Precio: \$${p.price.toStringAsFixed(2)}'),
              const SizedBox(height: 8),
              Text(
                inStock ? 'Disponibles: ${p.stock}' : 'Agotado',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: inStock ? Colors.green : Colors.red,
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: inStock
                    ? () {
                  context.read<CartProvider>().addProduct(p);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Producto agregado al carrito')),
                  );
                  Navigator.pop(context);
                }
                    : null,
                child: Text(inStock ? 'Agregar al carrito' : 'Sin stock'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
