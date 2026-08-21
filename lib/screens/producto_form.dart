import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../config.dart';
import '../models/producto.dart';
import '../services/cloudinary_service.dart';
import '../services/firestore_service.dart';

class ProductoFormScreen extends StatefulWidget {
  final Producto? producto;
  const ProductoFormScreen({super.key, this.producto});

  @override
  State<ProductoFormScreen> createState() => _ProductoFormScreenState();
}

class _ProductoFormScreenState extends State<ProductoFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nombreCtrl = TextEditingController();
  final _precioCtrl = TextEditingController();
  final _descripcionCtrl = TextEditingController();
  String _categoria = AppConfig.categorias.first;

  List<String> _imagenesExistentes = [];
  List<File> _imagenesNuevas = [];
  bool _guardando = false;

  @override
  void initState() {
    super.initState();
    if (widget.producto != null) {
      _nombreCtrl.text = widget.producto!.nombre;
      _precioCtrl.text = widget.producto!.precio.toString();
      _descripcionCtrl.text = widget.producto!.descripcion;
      _categoria = widget.producto!.categoria;
      _imagenesExistentes = List.from(widget.producto!.imagenes);
    }
  }

  Future<void> _elegirImagenes() async {
    final picker = ImagePicker();
    final archivos = await picker.pickMultiImage();
    if (archivos.isNotEmpty) {
      setState(() {
        _imagenesNuevas.addAll(archivos.map((x) => File(x.path)));
      });
    }
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;
    if (_imagenesExistentes.isEmpty && _imagenesNuevas.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Agrega al menos una foto')),
      );
      return;
    }

    setState(() => _guardando = true);

    try {
      List<String> urlsNuevas = [];
      if (_imagenesNuevas.isNotEmpty) {
        urlsNuevas = await CloudinaryService.subirImagenes(_imagenesNuevas);
      }

      final todasLasImagenes = [..._imagenesExistentes, ...urlsNuevas];

      final producto = Producto(
        id: widget.producto?.id,
        nombre: _nombreCtrl.text.trim(),
        categoria: _categoria,
        precio: double.tryParse(_precioCtrl.text.trim()) ?? 0,
        descripcion: _descripcionCtrl.text.trim(),
        imagenes: todasLasImagenes,
        fechaCreacion: widget.producto?.fechaCreacion,
      );

      if (widget.producto == null) {
        await FirestoreService.agregarProducto(producto);
      } else {
        await FirestoreService.actualizarProducto(producto);
      }

      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al guardar: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _guardando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final esEdicion = widget.producto != null;
    return Scaffold(
      appBar: AppBar(
        title: Text(esEdicion ? 'Editar producto' : 'Nuevo producto'),
        backgroundColor: const Color(0xFFD4AF37),
        foregroundColor: Colors.black,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _nombreCtrl,
              decoration: const InputDecoration(labelText: 'Nombre del producto'),
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Requerido' : null,
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _categoria,
              decoration: const InputDecoration(labelText: 'Categoría'),
              items: AppConfig.categorias
                  .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                  .toList(),
              onChanged: (v) => setState(() => _categoria = v!),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _precioCtrl,
              decoration: const InputDecoration(labelText: 'Precio'),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Requerido' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _descripcionCtrl,
              decoration: const InputDecoration(labelText: 'Descripción'),
              maxLines: 3,
            ),
            const SizedBox(height: 20),
            OutlinedButton.icon(
              onPressed: _elegirImagenes,
              icon: const Icon(Icons.add_photo_alternate_outlined),
              label: const Text('Agregar fotos'),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ..._imagenesExistentes.map((url) => Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(url, width: 90, height: 90, fit: BoxFit.cover),
                        ),
                        Positioned(
                          right: 0,
                          child: GestureDetector(
                            onTap: () => setState(() => _imagenesExistentes.remove(url)),
                            child: const CircleAvatar(
                              radius: 12,
                              backgroundColor: Colors.red,
                              child: Icon(Icons.close, size: 14, color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    )),
                ..._imagenesNuevas.map((file) => Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.file(file, width: 90, height: 90, fit: BoxFit.cover),
                        ),
                        Positioned(
                          right: 0,
                          child: GestureDetector(
                            onTap: () => setState(() => _imagenesNuevas.remove(file)),
                            child: const CircleAvatar(
                              radius: 12,
                              backgroundColor: Colors.red,
                              child: Icon(Icons.close, size: 14, color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    )),
              ],
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _guardando ? null : _guardar,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD4AF37),
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: _guardando
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(esEdicion ? 'Guardar cambios' : 'Publicar producto'),
            ),
          ],
        ),
      ),
    );
  }
}
