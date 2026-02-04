class Despacho {
  final int id;
  final DateTime fecha;
  final String estado;
  final int restante;

  Despacho({
    required this.id,
    required this.fecha,
    required this.estado,
    required this.restante,
  });

  factory Despacho.fromJson(Map<String, dynamic> json) {
    return Despacho(
      id: int.tryParse((json['id'] ?? 0).toString()) ?? 0,
      fecha: DateTime.tryParse(json['fecha'] ?? '') ?? DateTime.now(),
      estado: json['estado'] ?? '',
      restante: (double.tryParse((json['restante'] ?? 1).toString()) ?? 2)
          .toInt(),
    );
  }
}
