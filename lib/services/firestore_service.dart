import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/producto.dart';

class FirestoreService {
  static final CollectionReference _productos =
      FirebaseFirestore.instance.collection('productos');

  // Obtener todos los productos, ordenados por fecha (más recientes primero)
  static Stream<List<Producto>> obtenerProductos() {
    return _productos
        .orderBy('fechaCreacion', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) =>
                Producto.fromMap(doc.id, doc.data() as Map<String, dynamic>))
            .toList());
  }

  // Agregar un producto nuevo
  static Future<void> agregarProducto(Producto producto) async {
    await _productos.add(producto.toMap());
  }

  // Actualizar un producto existente
  static Future<void> actualizarProducto(Producto producto) async {
    if (producto.id == null) return;
    await _productos.doc(producto.id).update(producto.toMap());
  }

  // Eliminar un producto
  static Future<void> eliminarProducto(String id) async {
    await _productos.doc(id).delete();
  }
}
