class Producto {
  String? id;
  String nombre;
  String categoria;
  double precio;
  String descripcion;
  List<String> imagenes;
  DateTime? fechaCreacion;

  Producto({
    this.id,
    required this.nombre,
    required this.categoria,
    required this.precio,
    this.descripcion = '',
    this.imagenes = const [],
    this.fechaCreacion,
  });

  Map<String, dynamic> toMap() {
    return {
      'nombre': nombre,
      'categoria': categoria,
      'precio': precio,
      'descripcion': descripcion,
      'imagenes': imagenes,
      'fechaCreacion': fechaCreacion?.toIso8601String() ??
          DateTime.now().toIso8601String(),
    };
  }

  factory Producto.fromMap(String id, Map<String, dynamic> map) {
    return Producto(
      id: id,
      nombre: map['nombre'] ?? '',
      categoria: map['categoria'] ?? '',
      precio: (map['precio'] ?? 0).toDouble(),
      descripcion: map['descripcion'] ?? '',
      imagenes: List<String>.from(map['imagenes'] ?? []),
      fechaCreacion: map['fechaCreacion'] != null
          ? DateTime.tryParse(map['fechaCreacion'])
          : null,
    );
  }
}
