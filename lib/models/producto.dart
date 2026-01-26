class Producto {
  final int id;
  int cantidad = 0;
  final String nombre;
  final String unidad;
  final double precioUnitario;
  final double precioUnitarioMin;
  final double costoUnitario;
  final String categoriaId;
  final String categoriaNombre;

  Producto({
    required this.id,
    required this.nombre,
    required this.unidad,
    required this.precioUnitario,
    required this.precioUnitarioMin,
    required this.costoUnitario,
    required this.categoriaId,
    required this.categoriaNombre,
  });

  // Método para crear una instancia desde un Map (JSON)
  factory Producto.fromJson(Map<String, dynamic> json) {
    return Producto(
      id: int.tryParse((json['id'] ?? 0).toString()) ?? 0,
      nombre: json['nombre'] as String,
      unidad: json['unidad'] as String,
      precioUnitario: double.parse(json['precio_unitario'] as String),
      precioUnitarioMin: double.parse(json['precio_unitario_min'] as String),
      costoUnitario: double.parse(json['costo_unitario'] as String),
      categoriaId: json['categoria_id'] as String,
      categoriaNombre: json['categoria_nombre'] as String,
    );
  }

  // Método para convertir la instancia a Map (JSON)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'unidad': unidad,
      'precio_unitario': precioUnitario.toString(),
      'precio_unitario_min': precioUnitarioMin.toString(),
      'costo_unitario': costoUnitario.toString(),
      'categoria_id': categoriaId,
      'categoria_nombre': categoriaNombre,
    };
  }

  // Método copyWith para crear copias modificadas
  Producto copyWith({
    int? id,
    String? nombre,
    String? unidad,
    double? precioUnitario,
    double? precioUnitarioMin,
    double? costoUnitario,
    String? categoriaId,
    String? categoriaNombre,
  }) {
    return Producto(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      unidad: unidad ?? this.unidad,
      precioUnitario: precioUnitario ?? this.precioUnitario,
      precioUnitarioMin: precioUnitarioMin ?? this.precioUnitarioMin,
      costoUnitario: costoUnitario ?? this.costoUnitario,
      categoriaId: categoriaId ?? this.categoriaId,
      categoriaNombre: categoriaNombre ?? this.categoriaNombre,
    );
  }

  @override
  String toString() {
    return 'Producto{id: $id, nombre: $nombre, unidad: $unidad, precioUnitario: $precioUnitario, precioUnitarioMin: $precioUnitarioMin, costoUnitario: $costoUnitario, categoriaId: $categoriaId, categoriaNombre: $categoriaNombre}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Producto &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          nombre == other.nombre &&
          unidad == other.unidad &&
          precioUnitario == other.precioUnitario &&
          precioUnitarioMin == other.precioUnitarioMin &&
          costoUnitario == other.costoUnitario &&
          categoriaId == other.categoriaId &&
          categoriaNombre == other.categoriaNombre;

  @override
  int get hashCode =>
      id.hashCode ^
      nombre.hashCode ^
      unidad.hashCode ^
      precioUnitario.hashCode ^
      precioUnitarioMin.hashCode ^
      costoUnitario.hashCode ^
      categoriaId.hashCode ^
      categoriaNombre.hashCode;
}
