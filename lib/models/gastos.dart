class Gasto {
  final String detalle;
  final double valor;

  Gasto({required this.detalle, required this.valor});

  factory Gasto.fromJson(Map<String, dynamic> json) {
    return Gasto(
      detalle: json['detalle'] ?? '',
      valor: double.tryParse(json['valor'].toString()) ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {'detalle': detalle, 'valor': valor.toStringAsFixed(2)};
  }
}
