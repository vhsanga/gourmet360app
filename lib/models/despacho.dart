class Despacho {
  final int id;
  final DateTime fecha;
  final String estado;
  final int asignado;
  final double totalVentas;

  Despacho({
    required this.id,
    required this.fecha,
    required this.estado,
    required this.asignado,
    required this.totalVentas,
  });

  factory Despacho.fromJson(Map<String, dynamic> json) {
    return Despacho(
      id: int.tryParse((json['id'] ?? 0).toString()) ?? 0,
      fecha: DateTime.tryParse(json['fecha'] ?? '') ?? DateTime.now(),
      estado: json['estado'] ?? '',
      asignado: (double.tryParse((json['asignado'] ?? 1).toString()) ?? 2)
          .toInt(),
      totalVentas: double.tryParse((json['total_ventas'] ?? 0).toString()) ?? 0,
    );
  }
}
