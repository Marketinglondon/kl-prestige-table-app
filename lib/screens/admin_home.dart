import 'package:flutter/material.dart';
import '../config.dart';
import '../models/producto.dart';
import '../services/firestore_service.dart';
import 'producto_form.dart';

class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({super.key});

  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  String _busqueda = '';
  String _categoriaFiltro = 'Todas';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppConfig.appName),
        backgroundColor: const Color(0xFFD4AF37),
        foregroundColor: Colors.black,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Buscar producto...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onChanged: (value) => setState(() => _busqueda = value.toLowerCase()),
            ),
          ),
          SizedBox(
            height: 45,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              children: [
                _chipCategoria('Todas'),
                ...AppConfig.categorias.map((c) => _chipCategoria(c)),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: StreamBuilder<List<Producto>>(
              stream: FirestoreService.obtenerProductos(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('No hay productos todavía'));
                }

                var productos = snapshot.data!;
                if (_categoriaFiltro != 'Todas') {
                  productos = productos
                      .where((p) => p.categoria == _categoriaFiltro)
                      .toList();
                }
                if (_busqueda.isNotEmpty) {
                  productos = productos
                      .where((p) => p.nombre.toLowerCase().contains(_busqueda))
                      .toList();
                }

                if (productos.isEmpty) {
                  return const Center(child: Text('Sin resultados'));
                }

                return ListView.builder(
                  itemCount: productos.length,
                  itemBuilder: (context, index) {
                    final producto = productos[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      child: ListTile(
                        leading: producto.imagenes.isNotEmpty
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  producto.imagenes.first,
                                  width: 55,
                                  height: 55,
                                  fit: BoxFit.cover,
                                ),
                              )
                            : const Icon(Icons.table_bar, size: 40),
                        title: Text(producto.nombre),
                        subtitle: Text(
                            '${producto.categoria} • \$${producto.precio.toStringAsFixed(2)}'),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete_outline, color: Colors.red),
                          onPressed: () => _confirmarEliminar(producto),
                        ),
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ProductoFormScreen(producto: producto),
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFFD4AF37),
        child: const Icon(Icons.add, color: Colors.black),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ProductoFormScreen()),
          );
        },
      ),
    );
  }

  Widget _chipCategoria(String categoria) {
    final seleccionada = _categoriaFiltro == categoria;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: ChoiceChip(
        label: Text(categoria),
        selected: seleccionada,
        onSelected: (_) => setState(() => _categoriaFiltro = categoria),
        selectedColor: const Color(0xFFD4AF37),
      ),
    );
  }

  void _confirmarEliminar(Producto producto) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar producto'),
        content: Text('¿Seguro que quieres eliminar "${producto.nombre}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              FirestoreService.eliminarProducto(producto.id!);
              Navigator.pop(context);
            },
            child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
