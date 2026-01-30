class Despacho {
  final int id;
  final DateTime fecha;
  final String estado;

  Despacho({required this.id, required this.fecha, required this.estado});

  factory Despacho.fromJson(Map<String, dynamic> json) {
    return Despacho(
      id: int.tryParse((json['id'] ?? 0).toString()) ?? 0,
      fecha: DateTime.tryParse(json['fecha'] ?? '') ?? DateTime.now(),
      estado: json['estado'] ?? '',
    );
  }
}
