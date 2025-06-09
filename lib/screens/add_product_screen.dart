// lib/screens/add_product_screen.dart

import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:tienda/providers/product_provider.dart';
import 'package:tienda/models/product.dart';

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({super.key});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _formKey = GlobalKey<FormState>();
  String _name = '';
  String _description = '';
  String _priceText = '';
  int _stock = 1;
  List<PlatformFile> _mediaFiles = [];
  bool _isSaving = false;

  Future<void> _pickMedia() async {
    // 1) Pedir permisos apropiados
    if (Platform.isAndroid) {
      // Android 13+: photos/videos, Android ≤12: storage
      final statuses = await [
        Permission.photos,
        Permission.videos,
        Permission.storage,
      ].request();

      if (statuses[Permission.photos]    != PermissionStatus.granted ||
          statuses[Permission.videos]    != PermissionStatus.granted &&
              statuses[Permission.storage]  != PermissionStatus.granted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Permisos denegados')),
        );
        return;
      }
    }
    // 2) Abrir selector para imágenes y vídeos (múltiple)
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowMultiple: true,
      allowedExtensions: [
        'jpg','jpeg','png','JPG','JPEG','PNG',
        'mp4','mov','avi','MP4','MOV','AVI',
      ],
    );
    if (result != null) {
      setState(() => _mediaFiles = result.files);
    }
  }

  Future<String?> _uploadFile(PlatformFile file) async {
    final uri = Uri.parse('${ProductProvider.baseUrl}/upload');
    final req = http.MultipartRequest('POST', uri);
    req.files.add(await http.MultipartFile.fromPath('file', file.path!));
    final streamed = await req.send();
    final res = await http.Response.fromStream(streamed);
    if (res.statusCode == 200) {
      final data = json.decode(res.body) as Map<String, dynamic>;
      return data['url'] as String?;
    }
    return null;
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();
    setState(() => _isSaving = true);

    final List<Media> mediaList = [];
    for (final file in _mediaFiles) {
      final url = await _uploadFile(file);
      if (url == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al subir ${file.name}')),
        );
        setState(() => _isSaving = false);
        return;
      }
      final ext = file.extension?.toLowerCase() ?? '';
      mediaList.add(Media(
        url: url,
        type: ['mp4','mov','avi'].contains(ext) ? 'video' : 'image',
      ));
    }

    final newProduct = Product(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: _name,
      description: _description,
      price: double.parse(_priceText),
      stock: _stock,
      media: mediaList,
    );

    try {
      await context.read<ProductProvider>().createProductInDB(newProduct);
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Producto creado correctamente')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al crear: $e')),
      );
      setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Añadir Producto')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                decoration: const InputDecoration(labelText: 'Nombre'),
                onSaved: (v) => _name = v!.trim(),
                validator: (v) => v == null || v.isEmpty ? 'Requerido' : null,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Descripción'),
                onSaved: (v) => _description = v!.trim(),
                validator: (v) => v == null || v.isEmpty ? 'Requerido' : null,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Precio'),
                keyboardType: TextInputType.number,
                onSaved: (v) => _priceText = v!.trim(),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Requerido';
                  if (double.tryParse(v) == null) return 'Número inválido';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.remove_circle_outline),
                    onPressed: _stock > 1
                        ? () => setState(() => _stock--)
                        : null,
                  ),
                  Text('$_stock', style: const TextStyle(fontSize: 18)),
                  IconButton(
                    icon: const Icon(Icons.add_circle_outline),
                    onPressed: () => setState(() => _stock++),
                  ),
                  const SizedBox(width: 8),
                  const Text('Stock'),
                ],
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _pickMedia,
                child: const Text('Seleccionar fotos/videos'),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _mediaFiles.map((file) {
                  final ext = file.extension?.toLowerCase() ?? '';
                  if (['jpg','jpeg','png'].contains(ext)) {
                    return Image.file(
                      File(file.path!),
                      width: 100,
                      height: 100,
                      fit: BoxFit.cover,
                    );
                  } else {
                    return Container(
                      width: 100,
                      height: 100,
                      color: Colors.grey[300],
                      child: const Icon(Icons.videocam, size: 40),
                    );
                  }
                }).toList(),
              ),
              const SizedBox(height: 20),
              _isSaving
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                onPressed: _save,
                child: const Text('Guardar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
