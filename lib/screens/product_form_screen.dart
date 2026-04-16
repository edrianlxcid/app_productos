import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/api_service.dart';

class ProductFormScreen extends StatefulWidget {
  final String token;
  final dynamic product;

  const ProductFormScreen({super.key, required this.token, this.product});

  @override
  State<ProductFormScreen> createState() => _ProductFormScreenState();
}

class _ProductFormScreenState extends State<ProductFormScreen> {
  late TextEditingController descCtrl;
  late TextEditingController stockCtrl;
  late TextEditingController priceCtrl;
  File? imageFile;

  @override
  void initState() {
    super.initState();
    descCtrl = TextEditingController(
      text: widget.product?['description'] ?? '',
    );
    stockCtrl = TextEditingController(
      text: widget.product?['stock']?.toString() ?? '',
    );
    priceCtrl = TextEditingController(
      text: widget.product?['price']?.toString() ?? '',
    );
  }

  Future<void> pickImage() async {
    final picker = ImagePicker();
    final xfile = await picker.pickImage(source: ImageSource.gallery);

    if (xfile != null) {
      setState(() {
        imageFile = File(xfile.path);
      });
    }
  }

  Future<void> saveProduct() async {
    final fields = {
      'description': descCtrl.text,
      'stock': stockCtrl.text,
      'price': priceCtrl.text,
    };

    final id = widget.product?['id'] ?? widget.product?['_id'];

    if (id == null) {
      await ApiService.createProduct(widget.token, fields, imageFile);
    } else {
      await ApiService.updateProduct(widget.token, id, fields, imageFile);
    }

    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final currentImage = widget.product?['imageUrl'];

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.product == null ? 'Nuevo producto' : 'Editar producto',
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            TextField(
              controller: descCtrl,
              decoration: const InputDecoration(labelText: 'Descripción'),
            ),
            TextField(
              controller: stockCtrl,
              decoration: const InputDecoration(labelText: 'Stock'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: priceCtrl,
              decoration: const InputDecoration(labelText: 'Precio'),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            if (imageFile != null)
              Image.file(imageFile!, height: 150)
            else if (currentImage != null && currentImage.toString().isNotEmpty)
              Image.network(currentImage, height: 150)
            else
              const Text('Sin imagen'),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: pickImage,
              child: const Text('Seleccionar imagen'),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: saveProduct,
              child: const Text('Guardar'),
            ),
          ],
        ),
      ),
    );
  }
}
