class Cortesias {
  final int cantidad;
  final String nombre;

  Cortesias({required this.cantidad, required this.nombre});

  factory Cortesias.fromJson(Map<String, dynamic> json) {
    return Cortesias(
      cantidad: (double.tryParse(json['cantidad'].toString()) ?? 0).round(),
      nombre: json['nombre'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {'cantidad': cantidad, 'nombre': nombre};
  }
}
