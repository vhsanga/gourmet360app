class VentaProducto {
  final int id;
  final String nombre;
  final double cantidad;
  final double precioUnitario;
  final double subtotal;

  VentaProducto({
    required this.id,
    required this.nombre,
    required this.cantidad,
    required this.precioUnitario,
    required this.subtotal,
  });

  factory VentaProducto.fromJson(Map<String, dynamic> json) {
    return VentaProducto(
      id: int.parse(json['id'].toString()),
      nombre: json['nombre'] ?? '',
      cantidad: double.parse(json['cantidad'].toString()),
      precioUnitario: double.parse(json['precio_unitario'].toString()),
      subtotal: double.parse(json['subtotal'].toString()),
    );
  }
}
