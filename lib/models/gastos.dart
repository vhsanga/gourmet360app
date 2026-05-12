class Gasto {
  final String id;
  final String detalle;
  final double valor;

  Gasto({required this.id, required this.detalle, required this.valor});

  factory Gasto.fromJson(Map<String, dynamic> json) {
    return Gasto(
      id: json['id'] ?? '',
      detalle: json['detalle'] ?? '',
      valor: double.tryParse(json['valor'].toString()) ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'detalle': detalle, 'valor': valor.toStringAsFixed(2)};
  }
}
