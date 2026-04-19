class ProductoRestante {
  final String nombre;
  final int cantidad_restante;
  final int producto_id;

  ProductoRestante({
    required this.nombre,
    required this.cantidad_restante,
    required this.producto_id,
  });

  factory ProductoRestante.fromJson(Map<String, dynamic> json) {
    return ProductoRestante(
      nombre: _parseString(json['nombre']),
      cantidad_restante: _parseInt(json['cantidad_restante']),
      producto_id: _parseInt(json['producto_id']),
    );
  }

  static String _parseString(dynamic value) {
    if (value == null) return '';
    return value.toString();
  }

  static int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    final str = value.toString().trim();
    // Try to parse as double first (handles "200.00"), then convert to int
    final doubleValue = double.tryParse(str);
    if (doubleValue != null) return doubleValue.toInt();
    return 0;
  }

  Map<String, dynamic> toJson() {
    return {
      'nombre': nombre,
      'cantidad_restante': cantidad_restante,
      'producto_id': producto_id,
    };
  }

  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    return double.tryParse(value.toString().trim()) ?? 0.0;
  }

  ProductoRestante copyWith({
    String? nombre,
    int? cantidad_restante,
    int? producto_id,
  }) {
    return ProductoRestante(
      nombre: nombre ?? this.nombre,
      cantidad_restante: cantidad_restante ?? this.cantidad_restante,
      producto_id: producto_id ?? this.producto_id,
    );
  }

  @override
  String toString() {
    return 'ProductoRestante{nombre: $nombre, cantidad_restante: $cantidad_restante, producto_id: $producto_id}';
  }
}
