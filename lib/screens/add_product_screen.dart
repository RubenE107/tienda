import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../models/product.dart';
import '../providers/product_provider.dart';

class AddProductScreen extends StatefulWidget {
  @override
  _AddProductScreenState createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _imageUrlController = TextEditingController();
  final _priceController = TextEditingController();
  final _descriptionController = TextEditingController();
  File? _pickedImage;
  final ImagePicker _picker = ImagePicker();
  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _pickedImage = File(pickedFile.path);
      });
    }
  }

  void _saveProduct() {
    if (_formKey.currentState!.validate()) {
      final newProduct = Product(
        id: DateTime.now().millisecondsSinceEpoch,
        title: _titleController.text,
        image: _imageUrlController.text,
        price: double.tryParse(_priceController.text) ?? 0.0,
        description: _descriptionController.text,
      );

      Provider.of<ProductProvider>(
        context,
        listen: false,
      ).addProduct(newProduct);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Agregar Producto')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(labelText: 'Título'),
                validator:
                    (value) => value!.isEmpty ? 'Escribe un título' : null,
              ),
              // TextFormField(
              //   controller: _imageUrlController,
              //   decoration: InputDecoration(labelText: 'URL de imagen'),
              //   validator: (value) => value!.isEmpty ? 'Escribe una URL de imagen' : null,
              // ),
              TextFormField(
                controller: _imageUrlController,
                decoration: InputDecoration(labelText: 'URL de imagen'),
                validator: (value) {
                  if (value == null || value.isEmpty)
                    return 'Escribe una URL de imagen';
                  final uri = Uri.tryParse(value);
                  if (uri == null || !uri.isAbsolute) return 'URL no válida';
                  return null;
                },
              ),

              TextFormField(
                controller: _priceController,
                decoration: InputDecoration(labelText: 'Precio'),
                keyboardType: TextInputType.number,
                validator:
                    (value) => value!.isEmpty ? 'Escribe un precio' : null,
              ),
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(labelText: 'Descripción'),
                maxLines: 3,
                validator:
                    (value) =>
                        value!.isEmpty ? 'Escribe una descripción' : null,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveProduct,
                child: const Text('Guardar producto'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
