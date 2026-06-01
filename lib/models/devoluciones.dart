class Devoluciones {
  final int cantidad;
  final String nombre;

  Devoluciones({required this.cantidad, required this.nombre});

  factory Devoluciones.fromJson(Map<String, dynamic> json) {
    return Devoluciones(
      cantidad: (double.tryParse(json['cantidad'].toString()) ?? 0).round(),
      nombre: json['nombre'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {'cantidad': cantidad, 'nombre': nombre};
  }
}
